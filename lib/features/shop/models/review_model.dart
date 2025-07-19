import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String id;
  String productId;
  String userId;
  String userName;
  String userProfileImage;
  double rating;
  String reviewText;
  DateTime reviewDate;
  bool isVerifiedPurchase;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userProfileImage = '',
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    this.isVerifiedPurchase = false,
  });

  // Empty Helper Function
  static ReviewModel empty() => ReviewModel(
        id: '',
        productId: '',
        userId: '',
        userName: '',
        rating: 0.0,
        reviewText: '',
        reviewDate: DateTime.now(),
      );

  // Convert model to JSON structure for Firebase
  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'UserId': userId,
      'UserName': userName,
      'UserProfileImage': userProfileImage,
      'Rating': rating,
      'ReviewText': reviewText,
      'ReviewDate': reviewDate.toIso8601String(),
      'IsVerifiedPurchase': isVerifiedPurchase,
    };
  }

  // Map JSON document snapshot from Firebase to ReviewModel
  factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      return ReviewModel(
        id: document.id,
        productId: data['ProductId'] ?? '',
        userId: data['UserId'] ?? '',
        userName: data['UserName'] ?? '',
        userProfileImage: data['UserProfileImage'] ?? '',
        rating: double.parse((data['Rating'] ?? 0.0).toString()),
        reviewText: data['ReviewText'] ?? '',
        reviewDate: data['ReviewDate'] != null 
            ? DateTime.parse(data['ReviewDate']) 
            : DateTime.now(),
        isVerifiedPurchase: data['IsVerifiedPurchase'] ?? false,
      );
    } else {
      return ReviewModel.empty();
    }
  }

  // Map JSON query document snapshot from Firebase to ReviewModel
  factory ReviewModel.fromQuerySnapshot(QueryDocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    return ReviewModel(
      id: document.id,
      productId: data['ProductId'] ?? '',
      userId: data['UserId'] ?? '',
      userName: data['UserName'] ?? '',
      userProfileImage: data['UserProfileImage'] ?? '',
      rating: double.parse((data['Rating'] ?? 0.0).toString()),
      reviewText: data['ReviewText'] ?? '',
      reviewDate: data['ReviewDate'] != null 
          ? DateTime.parse(data['ReviewDate']) 
          : DateTime.now(),
      isVerifiedPurchase: data['IsVerifiedPurchase'] ?? false,
    );
  }

  // Copy with method for updating review
  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userProfileImage,
    double? rating,
    String? reviewText,
    DateTime? reviewDate,
    bool? isVerifiedPurchase,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      reviewDate: reviewDate ?? this.reviewDate,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }

  // Get formatted review date
  String get formattedReviewDate {
    final now = DateTime.now();
    final difference = now.difference(reviewDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Model for review statistics
class ReviewStatistics {
  double averageRating;
  int totalReviews;
  Map<int, int> ratingCounts; // {5: 120, 4: 80, 3: 30, 2: 10, 1: 5}

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  static ReviewStatistics empty() => ReviewStatistics(
        averageRating: 0.0,
        totalReviews: 0,
        ratingCounts: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );

  // Get percentage for each rating
  double getRatingPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    return (ratingCounts[rating] ?? 0) / totalReviews;
  }

  // Get count for specific rating
  int getRatingCount(int rating) {
    return ratingCounts[rating] ?? 0;
  }
} 