import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/review_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class ReviewRepository extends GetxController {
  static ReviewRepository get instance => Get.find();

  // Variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all reviews for a product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      print('📦 Fetching reviews for ProductId: $productId'); // Debug log
      
      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .get();

      print('📋 Found ${snapshot.docs.length} reviews'); // Debug log
      
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
          
      // Sort manually to avoid index requirement initially
      reviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
      
      return reviews;
    } on FirebaseException catch (e) {
      print('🔥 Firebase Error: ${e.code} - ${e.message}'); // Debug log
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      print('📱 Platform Error: ${e.code} - ${e.message}'); // Debug log
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('❌ General Error: $e'); // Debug log
      throw 'Something went wrong. Please try again';
    }
  }

  // Get review statistics for a product
  Future<ReviewStatistics> getProductReviewStatistics(String productId) async {
    try {
      print('📊 Calculating statistics for ProductId: $productId');
      
      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .get();

      print('📈 Found ${snapshot.docs.length} reviews for statistics');

      if (snapshot.docs.isEmpty) {
        print('📊 No reviews found, returning empty statistics');
        return ReviewStatistics.empty();
      }

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();

      // Calculate statistics
      double totalRating = 0.0;
      Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (final review in reviews) {
        totalRating += review.rating;
        final ratingInt = review.rating.round();
        ratingCounts[ratingInt] = (ratingCounts[ratingInt] ?? 0) + 1;
      }

      final averageRating = totalRating / reviews.length;
      
      print('⭐ Average rating: $averageRating, Total reviews: ${reviews.length}');

      return ReviewStatistics(
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingCounts: ratingCounts,
      );
    } on FirebaseException catch (e) {
      print('🔥 Firebase Error in getProductReviewStatistics: ${e.code} - ${e.message}');
      return ReviewStatistics.empty(); // Return empty instead of throwing error
    } on PlatformException catch (e) {
      print('📱 Platform Error in getProductReviewStatistics: ${e.code} - ${e.message}');
      return ReviewStatistics.empty(); // Return empty instead of throwing error
    } catch (e) {
      print('❌ General Error in getProductReviewStatistics: $e');
      return ReviewStatistics.empty(); // Return empty instead of throwing error
    }
  }

  // Update product rating in Products collection
  Future<void> _updateProductRating(String productId) async {
    try {
      // Get all reviews for this product
      final reviewStats = await getProductReviewStatistics(productId);
      
      // Update the product document with new rating and review count
      await _db.collection('Products').doc(productId).update({
        'Rating': reviewStats.averageRating,
        'ReviewCount': reviewStats.totalReviews,
      });
    } catch (e) {
      print('Error updating product rating: $e');
      // Don't throw error here as review creation should not fail if rating update fails
    }
  }

  // Check if user has purchased the product (only delivered orders)
  Future<bool> hasUserPurchasedProduct(String productId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      print('🔍 Checking purchase for ProductId: $productId, UserId: ${currentUser.uid}');

      final ordersSnapshot = await _db
          .collection('Orders')
          .where('UserId', isEqualTo: currentUser.uid)
          .where('Status', isEqualTo: 'delivered') // Only delivered orders can review
          .get();

      print('📦 Found ${ordersSnapshot.docs.length} delivered orders');

      for (final orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final items = orderData['Items'] as List<dynamic>? ?? [];
        
        print('🛍️ Order ${orderDoc.id} has ${items.length} items');
        
        for (final item in items) {
          if (item['ProductId'] == productId) {
            print('✅ Product found in delivered order!');
            return true;
          }
        }
      }

      print('❌ Product not found in any delivered orders');
      return false;
    } on FirebaseException catch (e) {
      print('🔥 Firebase Error in hasUserPurchasedProduct: ${e.code} - ${e.message}');
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      print('📱 Platform Error in hasUserPurchasedProduct: ${e.code} - ${e.message}');
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('❌ General Error in hasUserPurchasedProduct: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  // Check if user has already reviewed the product
  Future<bool> hasUserReviewedProduct(String productId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .where('UserId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get user's review for a product
  Future<ReviewModel?> getUserReviewForProduct(String productId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .where('UserId', isEqualTo: currentUser.uid)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ReviewModel.fromQuerySnapshot(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Add a new review
  Future<String> addReview(ReviewModel review) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Check if user has purchased the product
      final hasPurchased = await hasUserPurchasedProduct(review.productId);
      if (!hasPurchased) {
        throw 'You can only review products you have purchased';
      }

      // Check if user has already reviewed this product
      final hasReviewed = await hasUserReviewedProduct(review.productId);
      if (hasReviewed) {
        throw 'You have already reviewed this product';
      }

      // Add the review
      final docRef = await _db.collection('Reviews').add(review.toJson());
      
      // Update product rating
      await _updateProductRating(review.productId);
      
      return docRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Update an existing review
  Future<void> updateReview(String reviewId, ReviewModel updatedReview) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Check if the review belongs to the current user
      final reviewDoc = await _db.collection('Reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw 'Review not found';
      }

      final reviewData = reviewDoc.data()!;
      if (reviewData['UserId'] != currentUser.uid) {
        throw 'You can only update your own reviews';
      }

      await _db.collection('Reviews').doc(reviewId).update(updatedReview.toJson());
      
      // Update product rating
      await _updateProductRating(updatedReview.productId);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // Get review data before deletion
      final reviewDoc = await _db.collection('Reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw 'Review not found';
      }

      final reviewData = reviewDoc.data()!;
      if (reviewData['UserId'] != currentUser.uid) {
        throw 'You can only delete your own reviews';
      }

      final productId = reviewData['ProductId'] as String;

      // Delete the review
      await _db.collection('Reviews').doc(reviewId).delete();
      
      // Update product rating
      await _updateProductRating(productId);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Get user's own reviews
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _db
          .collection('Reviews')
          .where('UserId', isEqualTo: currentUser.uid)
          .orderBy('ReviewDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get reviews with pagination
  Future<List<ReviewModel>> getProductReviewsPaginated({
    required String productId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .orderBy('ReviewDate', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // ADMIN MONITORING METHODS
  
  // Get all reviews for admin panel (with pagination)
  Future<List<ReviewModel>> getAllReviewsForAdmin({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _db
          .collection('Reviews')
          .orderBy('ReviewDate', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get reviews by rating for admin filtering
  Future<List<ReviewModel>> getReviewsByRating(double rating) async {
    try {
      final snapshot = await _db
          .collection('Reviews')
          .where('Rating', isEqualTo: rating)
          .orderBy('ReviewDate', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get recent reviews for admin dashboard
  Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final snapshot = await _db
          .collection('Reviews')
          .orderBy('ReviewDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get review analytics for admin
  Future<Map<String, dynamic>> getReviewAnalytics() async {
    try {
      final snapshot = await _db.collection('Reviews').get();
      
      if (snapshot.docs.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
          'reviewsThisMonth': 0,
          'topRatedProducts': [],
        };
      }

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();

      // Calculate analytics
      double totalRating = 0.0;
      Map<int, int> ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      int reviewsThisMonth = 0;
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      for (final review in reviews) {
        totalRating += review.rating;
        final ratingInt = review.rating.round();
        ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
        
        if (review.reviewDate.isAfter(firstDayOfMonth)) {
          reviewsThisMonth++;
        }
      }

      return {
        'totalReviews': reviews.length,
        'averageRating': totalRating / reviews.length,
        'ratingDistribution': ratingDistribution,
        'reviewsThisMonth': reviewsThisMonth,
      };
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Admin delete review (for moderation)
  Future<void> adminDeleteReview(String reviewId) async {
    try {
      // Get review data before deletion
      final reviewDoc = await _db.collection('Reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        throw 'Review not found';
      }

      final reviewData = reviewDoc.data()!;
      final productId = reviewData['ProductId'] as String;

      // Delete the review
      await _db.collection('Reviews').doc(reviewId).delete();
      
      // Update product rating
      await _updateProductRating(productId);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Search reviews by user name or review text (for admin)
  Future<List<ReviewModel>> searchReviews(String searchTerm) async {
    try {
      // This is a basic implementation. For better search, consider using Algolia or similar
      final snapshot = await _db
          .collection('Reviews')
          .orderBy('ReviewDate', descending: true)
          .limit(100)
          .get();

      final allReviews = snapshot.docs
          .map((doc) => ReviewModel.fromQuerySnapshot(doc))
          .toList();

      // Filter reviews based on search term
      final filteredReviews = allReviews.where((review) {
        final searchLower = searchTerm.toLowerCase();
        return review.userName.toLowerCase().contains(searchLower) ||
               review.reviewText.toLowerCase().contains(searchLower);
      }).toList();

      return filteredReviews;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
} 