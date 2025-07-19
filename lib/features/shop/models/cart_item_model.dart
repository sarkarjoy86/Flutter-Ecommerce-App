import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  String id;
  String userId;
  String productId;
  String productTitle;
  String productImage;
  double price;
  int quantity;
  String? variationId;
  Map<String, dynamic> selectedAttributes;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.variationId,
    this.selectedAttributes = const {},
  });

  // Empty Helper Function
  static CartItemModel empty() => CartItemModel(
    id: '',
    userId: '',
    productId: '',
    productTitle: '',
    productImage: '',
    price: 0.0,
    quantity: 0,
  );

  // Convert model to JSON structure for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'variationId': variationId,
      'selectedAttributes': selectedAttributes,
    };
  }

  // Map JSON document snapshot from Firebase to CartItemModel
  factory CartItemModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      return CartItemModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        productId: data['ProductId'] ?? '',
        productTitle: data['ProductTitle'] ?? '',
        productImage: data['ProductImage'] ?? '',
        price: double.parse((data['Price'] ?? 0.0).toString()),
        quantity: int.parse((data['Quantity'] ?? 0).toString()),
        variationId: data['VariationId'],
        selectedAttributes: Map<String, dynamic>.from(data['SelectedAttributes'] ?? {}),
      );
    } else {
      return CartItemModel.empty();
    }
  }

  // Create CartItemModel from JSON (for local storage)
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      price: double.parse((json['price'] ?? 0.0).toString()),
      quantity: int.parse((json['quantity'] ?? 0).toString()),
      variationId: json['variationId'],
      selectedAttributes: Map<String, dynamic>.from(json['selectedAttributes'] ?? {}),
    );
  }

  // Calculate total price for this cart item
  double get totalPrice => price * quantity;

  // Copy with method for updating cart item
  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productTitle,
    String? productImage,
    double? price,
    int? quantity,
    String? variationId,
    Map<String, dynamic>? selectedAttributes,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variationId: variationId ?? this.variationId,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
    );
  }
} 