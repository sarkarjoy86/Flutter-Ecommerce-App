import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  String id;
  String userId;
  String productId;
  String productTitle;
  String productImage;
  double price;
  String categoryId;
  String brandId;

  WishlistItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.price,
    required this.categoryId,
    required this.brandId,
  });

  // Empty Helper Function
  static WishlistItemModel empty() => WishlistItemModel(
    id: '',
    userId: '',
    productId: '',
    productTitle: '',
    productImage: '',
    price: 0.0,
    categoryId: '',
    brandId: '',
  );

  // Convert model to JSON structure for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'price': price,
      'categoryId': categoryId,
      'brandId': brandId,
    };
  }

  // Create WishlistItemModel from JSON (for local storage)
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      price: double.parse((json['price'] ?? 0.0).toString()),
      categoryId: json['categoryId'] ?? '',
      brandId: json['brandId'] ?? '',
    );
  }

  // Copy with method for updating wishlist item
  WishlistItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productTitle,
    String? productImage,
    double? price,
    String? categoryId,
    String? brandId,
  }) {
    return WishlistItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
    );
  }

  // Map JSON document snapshot from Firebase to WishlistItemModel
  factory WishlistItemModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      return WishlistItemModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        productId: data['ProductId'] ?? '',
        productTitle: data['ProductTitle'] ?? '',
        productImage: data['ProductImage'] ?? '',
        price: double.parse((data['Price'] ?? 0.0).toString()),
        categoryId: data['CategoryId'] ?? '',
        brandId: data['BrandId'] ?? '',
      );
    } else {
      return WishlistItemModel.empty();
    }
  }
} 