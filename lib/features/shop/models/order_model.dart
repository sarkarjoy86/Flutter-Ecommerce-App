import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String id;
  String userId;
  String customerName;
  String orderNumber;
  List<OrderItemModel> items;
  double totalAmount;
  OrderStatus status;
  ShippingAddress shippingAddress;
  DateTime orderDate;
  String? trackingNumber;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.orderNumber,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.orderDate,
    this.trackingNumber,
  });

  // Empty Helper Function
  static OrderModel empty() => OrderModel(
    id: '',
    userId: '',
    customerName: '',
    orderNumber: '',
    items: [],
    totalAmount: 0.0,
    status: OrderStatus.pending,
    shippingAddress: ShippingAddress.empty(),
    orderDate: DateTime.now(),
  );

  // Convert model to JSON structure for Firebase
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'CustomerName': customerName,
      'OrderNumber': orderNumber,
      'Items': items.map((item) => item.toJson()).toList(),
      'TotalAmount': totalAmount,
      'Status': status.name,
      'ShippingAddress': shippingAddress.toJson(),
      'OrderDate': orderDate.toIso8601String(),
      'TrackingNumber': trackingNumber,
    };
  }

  // Map JSON document snapshot from Firebase to OrderModel
  factory OrderModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      return OrderModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        customerName: data['CustomerName'] ?? '',
        orderNumber: data['OrderNumber'] ?? '',
        items: (data['Items'] as List<dynamic>?)?.map((item) => OrderItemModel.fromJson(item)).toList() ?? [],
        totalAmount: double.parse((data['TotalAmount'] ?? 0.0).toString()),
        status: OrderStatus.values.firstWhere((e) => e.name == data['Status'], orElse: () => OrderStatus.pending),
        shippingAddress: ShippingAddress.fromJson(data['ShippingAddress'] ?? {}),
        orderDate: data['OrderDate'] != null ? DateTime.parse(data['OrderDate']) : DateTime.now(),
        trackingNumber: data['TrackingNumber'],
      );
    } else {
      return OrderModel.empty();
    }
  }
}

class OrderItemModel {
  String productId;
  String productTitle;
  double price;
  int quantity;
  String? size; // Only size from attributes

  OrderItemModel({
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.quantity,
    this.size,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'ProductTitle': productTitle,
      'Price': price,
      'Quantity': quantity,
      'Size': size,
    };
  }

  // Create from JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['ProductId'] ?? '',
      productTitle: json['ProductTitle'] ?? '',
      price: double.parse((json['Price'] ?? 0.0).toString()),
      quantity: int.parse((json['Quantity'] ?? 0).toString()),
      size: json['Size'],
    );
  }

  // Calculate total price for this order item
  double get totalPrice => price * quantity;
}

class ShippingAddress {
  String fullName;
  String phone;
  String street;
  String city;
  String state;
  String zipCode;
  String country;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  // Empty Helper Function
  static ShippingAddress empty() => ShippingAddress(
    fullName: '',
    phone: '',
    street: '',
    city: '',
    state: '',
    zipCode: '',
    country: '',
  );

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'FullName': fullName,
      'Phone': phone,
      'Street': street,
      'City': city,
      'State': state,
      'ZipCode': zipCode,
      'Country': country,
    };
  }

  // Create from JSON
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['FullName'] ?? '',
      phone: json['Phone'] ?? '',
      street: json['Street'] ?? '',
      city: json['City'] ?? '',
      state: json['State'] ?? '',
      zipCode: json['ZipCode'] ?? '',
      country: json['Country'] ?? '',
    );
  }
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
} 