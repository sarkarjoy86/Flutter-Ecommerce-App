import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/progress_indicator_and_rating.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/user_review_card.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/product_cards/rating/rating_indicator.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/review_controller.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import 'write_review_screen.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final ReviewController reviewController = Get.find<ReviewController>();

  @override
  void initState() {
    super.initState();
    // Initialize reviews when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.initializeReviews(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: TAppBar(
        title: const Text('Reviews & Ratings'),
        showBackArrow: true,
        actions: [
          // Write/Update Review Button
          Obx(() => IconButton(
                onPressed: reviewController.canWriteReview.value ||
                        reviewController.hasUserReviewed.value
                    ? () => _handleReviewAction()
                    : null,
                icon: Icon(
                  reviewController.hasUserReviewed.value
                      ? Iconsax.edit
                      : Iconsax.add,
                  color: reviewController.canWriteReview.value ||
                          reviewController.hasUserReviewed.value
                      ? TColors.primary
                      : TColors.grey,
                ),
                tooltip: reviewController.getButtonText(),
              )),
        ],
      ),

      // Body
      body: Obx(() {
        if (reviewController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => reviewController.initializeReviews(widget.product),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ratings and reviews are verified and are from people who use the same type of device that you use.",
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Overall Product Ratings - Dynamic
                  _buildOverallRating(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Sort and Filter Options
                  _buildSortAndFilterSection(),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Reviews List - Dynamic
                  _buildReviewsList(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverallRating() {
    return Obx(() {
      final stats = reviewController.reviewStatistics.value;
      
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                TRatingBarIndicator(
                  rating: stats.averageRating,
                ),
                Text(
                  '${stats.totalReviews} reviews',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                TRatingProgressIndicator(
                  text: '5',
                  value: stats.getRatingPercentage(5),
                ),
                TRatingProgressIndicator(
                  text: '4',
                  value: stats.getRatingPercentage(4),
                ),
                TRatingProgressIndicator(
                  text: '3',
                  value: stats.getRatingPercentage(3),
                ),
                TRatingProgressIndicator(
                  text: '2',
                  value: stats.getRatingPercentage(2),
                ),
                TRatingProgressIndicator(
                  text: '1',
                  value: stats.getRatingPercentage(1),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }


  Widget _buildSortAndFilterSection() {
    return Row(
      children: [
        // Sort Dropdown
        Flexible(
          child: Obx(() => DropdownButtonFormField<String>(
                value: reviewController.sortOption.value,
                decoration: const InputDecoration(
                  labelText: 'Sort By',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  const DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                  const DropdownMenuItem(value: 'highest', child: Text('Highest Rating')),
                  const DropdownMenuItem(value: 'lowest', child: Text('Lowest Rating')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    reviewController.changeSortOption(value);
                  }
                },
              )),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        
        // Filter by Rating
        Flexible(
          child: Obx(() => DropdownButtonFormField<int>(
                value: reviewController.filterRating.value,
                decoration: const InputDecoration(
                  labelText: 'Filter Rating',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('All Ratings')),
                  const DropdownMenuItem(value: 5, child: Text('5 Stars')),
                  const DropdownMenuItem(value: 4, child: Text('4 Stars')),
                  const DropdownMenuItem(value: 3, child: Text('3 Stars')),
                  const DropdownMenuItem(value: 2, child: Text('2 Stars')),
                  const DropdownMenuItem(value: 1, child: Text('1 Star')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    reviewController.changeFilterRating(value);
                  }
                },
              )),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return Obx(() {
      if (reviewController.reviews.isEmpty) {
        return _buildEmptyReviews();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          Text(
            'Customer Reviews (${reviewController.reviews.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Reviews List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewController.reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              final review = reviewController.reviews[index];
              return UserReviewCard(
                review: review,
                onEdit: reviewController.canModifyReview(review)
                    ? () => _editReview(review)
                    : null,
                onDelete: reviewController.canModifyReview(review)
                    ? () => _deleteReview(review)
                    : null,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: TSizes.spaceBtwSections),
          Icon(
            Iconsax.star,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'No Reviews Yet',
            style: Theme.of(context).textTheme.headlineSmall?.apply(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Text(
            'Be the first to review this product!',
            style: Theme.of(context).textTheme.bodyMedium?.apply(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
        ],
      ),
    );
  }

  void _handleReviewAction() {
    if (reviewController.hasUserReviewed.value) {
      // Edit existing review
      _editReview(reviewController.userReview.value!);
    } else if (reviewController.canWriteReview.value) {
      // Write new review
      _writeNewReview();
    }
  }

  void _writeNewReview() {
    Get.to(() => WriteReviewScreen(
          product: widget.product,
          isEditing: false,
        ));
  }

  void _editReview(ReviewModel review) {
    Get.to(() => WriteReviewScreen(
          product: widget.product,
          isEditing: true,
          existingReview: review,
        ));
  }

  void _deleteReview(ReviewModel review) {
    reviewController.deleteReview(review.id, widget.product.id);
  }
}



