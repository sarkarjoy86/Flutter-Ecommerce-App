import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/reviews/review_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../screens/product_reviews/product_revies.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  // Variables
  final reviewRepository = Get.find<ReviewRepository>();
  RxBool isLoading = false.obs;
  
  // Review data
  final reviews = <ReviewModel>[].obs;
  final reviewStatistics = ReviewStatistics.empty().obs;
  
  // User review status
  final canWriteReview = false.obs;
  final hasUserReviewed = false.obs;
  final userReview = Rxn<ReviewModel>();
  
  // Form controllers
  final reviewTextController = TextEditingController();
  final selectedRating = 0.0.obs;
  
  // Sort and filter options
  final sortOption = 'newest'.obs;
  final filterRating = 0.obs; // 0 means all ratings

  @override
  void onClose() {
    reviewTextController.dispose();
    super.onClose();
  }

  // Initialize reviews for a product
  Future<void> initializeReviews(ProductModel product) async {
    try {
      isLoading.value = true;
      
      // Load reviews and statistics
      await Future.wait([
        loadProductReviews(product.id),
        loadReviewStatistics(product.id),
        checkUserReviewStatus(product.id),
      ]);
      
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Load product reviews
  Future<void> loadProductReviews(String productId) async {
    try {
      final productReviews = await reviewRepository.getProductReviews(productId);
      reviews.assignAll(productReviews);
      applySortAndFilter();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Load review statistics
  Future<void> loadReviewStatistics(String productId) async {
    try {
      final stats = await reviewRepository.getProductReviewStatistics(productId);
      reviewStatistics.value = stats;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Check if user can write review and if they already have one
  Future<void> checkUserReviewStatus(String productId) async {
    try {
      final hasPurchased = await reviewRepository.hasUserPurchasedProduct(productId);
      final hasReviewed = await reviewRepository.hasUserReviewedProduct(productId);
      
      canWriteReview.value = hasPurchased && !hasReviewed;
      hasUserReviewed.value = hasReviewed;
      
      if (hasReviewed) {
        userReview.value = await reviewRepository.getUserReviewForProduct(productId);
      }
    } catch (e) {
      canWriteReview.value = false;
      hasUserReviewed.value = false;
    }
  }

  // Submit a new review
  Future<void> submitReview(BuildContext context, ProductModel product, String userId, String userName, {String userProfileImage = ''}) async {
    try {
      // Validation
      if (selectedRating.value == 0) {
        TLoaders.warningSnackBar(title: 'Rating Required', message: 'Please select a rating');
        return;
      }
      
      if (reviewTextController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Review Required', message: 'Please write a review');
        return;
      }
      
      if (reviewTextController.text.trim().length < 10) {
        TLoaders.warningSnackBar(title: 'Review Too Short', message: 'Review must be at least 10 characters');
        return;
      }

      // Start loading
      TFullScreenLoader.openLoadingDialog('Submitting your review...', TImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Create review model
      final review = ReviewModel(
        id: '', // Will be set by Firestore
        productId: product.id,
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        rating: selectedRating.value,
        reviewText: reviewTextController.text.trim(),
        reviewDate: DateTime.now(),
        isVerifiedPurchase: true, // Will be verified by repository
      );

      // Submit review
      await reviewRepository.addReview(review);

      // Clear form
      reviewTextController.clear();
      selectedRating.value = 0.0;

      // Refresh data
      await Future.wait([
        loadProductReviews(product.id),
        loadReviewStatistics(product.id),
        checkUserReviewStatus(product.id),
      ]);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Review Submitted!',
        message: 'Thank you for your review. It has been published.',
      );

      // Redirect to ProductReviewsScreen
      Get.off(() => ProductReviewsScreen(product: product));

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Update existing review
  Future<void> updateReview(BuildContext context, String reviewId, ProductModel product) async {
    try {
      // Validation
      if (selectedRating.value == 0) {
        TLoaders.warningSnackBar(title: 'Rating Required', message: 'Please select a rating');
        return;
      }
      
      if (reviewTextController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Review Required', message: 'Please write a review');
        return;
      }

      // Start loading
      TFullScreenLoader.openLoadingDialog('Updating your review...', TImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update review
      final currentReview = userReview.value!;
      final updatedReview = currentReview.copyWith(
        rating: selectedRating.value,
        reviewText: reviewTextController.text.trim(),
      );

      await reviewRepository.updateReview(reviewId, updatedReview);

      // Clear form
      reviewTextController.clear();
      selectedRating.value = 0.0;

      // Refresh data
      await Future.wait([
        loadProductReviews(product.id),
        loadReviewStatistics(product.id),
        checkUserReviewStatus(product.id),
      ]);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Review Updated!',
        message: 'Your review has been successfully updated.',
      );

      // Redirect to ProductReviewsScreen
      Get.off(() => ProductReviewsScreen(product: product));

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId, String productId) async {
    try {
      // Confirmation dialog
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete your review? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (result != true) return;

      // Start loading
      TFullScreenLoader.openLoadingDialog('Deleting review...', TImages.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Delete review
      await reviewRepository.deleteReview(reviewId);

      // Refresh data
      await Future.wait([
        loadProductReviews(productId),
        loadReviewStatistics(productId),
        checkUserReviewStatus(productId),
      ]);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Review Deleted',
        message: 'Your review has been successfully deleted.',
      );

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Sort and filter reviews (user's review always at top)
  void applySortAndFilter() {
    var filteredReviews = List<ReviewModel>.from(reviews);

    // Apply rating filter
    if (filterRating.value > 0) {
      filteredReviews = filteredReviews
          .where((review) => review.rating.round() == filterRating.value)
          .toList();
    }

    // Separate user's review from others
    ReviewModel? currentUserReview;
    List<ReviewModel> otherReviews = [];
    
    final currentUserId = userReview.value?.userId;
    
    for (final review in filteredReviews) {
      if (currentUserId != null && review.userId == currentUserId) {
        currentUserReview = review;
      } else {
        otherReviews.add(review);
      }
    }

    // Apply sorting to other reviews
    switch (sortOption.value) {
      case 'newest':
        otherReviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
        break;
      case 'oldest':
        otherReviews.sort((a, b) => a.reviewDate.compareTo(b.reviewDate));
        break;
      case 'highest':
        otherReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        otherReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    // Combine: user's review first, then others
    final sortedReviews = <ReviewModel>[];
    if (currentUserReview != null) {
      sortedReviews.add(currentUserReview);
    }
    sortedReviews.addAll(otherReviews);

    reviews.assignAll(sortedReviews);
  }

  // Change sort option
  void changeSortOption(String option) {
    sortOption.value = option;
    applySortAndFilter();
  }

  // Change filter rating
  void changeFilterRating(int rating) {
    filterRating.value = rating;
    applySortAndFilter();
  }

  // Prepare form for editing existing review
  void prepareEditReview(ReviewModel review) {
    reviewTextController.text = review.reviewText;
    selectedRating.value = review.rating;
  }

  // Clear form
  void clearForm() {
    reviewTextController.clear();
    selectedRating.value = 0.0;
  }

  // Get rating distribution for UI
  List<double> getRatingDistribution() {
    final stats = reviewStatistics.value;
    return [
      stats.getRatingPercentage(5),
      stats.getRatingPercentage(4),
      stats.getRatingPercentage(3),
      stats.getRatingPercentage(2),
      stats.getRatingPercentage(1),
    ];
  }

  // Get rating counts for UI
  List<int> getRatingCounts() {
    final stats = reviewStatistics.value;
    return [
      stats.getRatingCount(5),
      stats.getRatingCount(4),
      stats.getRatingCount(3),
      stats.getRatingCount(2),
      stats.getRatingCount(1),
    ];
  }

  // Format rating percentage for display
  String formatPercentage(double percentage) {
    return '${(percentage * 100).round()}%';
  }

  // Get review status text
  String getReviewStatusText() {
    if (canWriteReview.value) {
      return 'You can write a review for this product';
    } else if (hasUserReviewed.value) {
      return 'You have already reviewed this product';
    } else {
      return 'Purchase this product to write a review';
    }
  }

  // Get button text based on user review status
  String getButtonText() {
    if (hasUserReviewed.value) {
      return 'Edit Review';
    } else {
      return 'Write Review';
    }
  }

  // Check if user can edit/delete review
  bool canModifyReview(ReviewModel review) {
    return userReview.value?.id == review.id;
  }
} 