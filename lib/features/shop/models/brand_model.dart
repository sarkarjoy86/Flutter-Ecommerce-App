import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  String id;
  String name;
  String description;
  String image;
  String logo;
  bool isFeatured;
  bool isActive;
  int productCount;

  BrandModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.logo,
    this.isFeatured = false,
    this.isActive = true,
    this.productCount = 0,
  });

  // Empty Helper Function
  static BrandModel empty() => BrandModel(
    id: '',
    name: '',
    description: '',
    image: '',
    logo: '',
  );

  // Convert model to JSON structure for Firebase
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'Image': image,
      'Logo': logo,
      'IsFeatured': isFeatured,
      'IsActive': isActive,
      'ProductCount': productCount,
    };
  }

  // Map JSON document snapshot from Firebase to BrandModel
  factory BrandModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      return BrandModel(
        id: document.id,
        name: data['Name'] ?? '',
        description: data['Description'] ?? '',
        image: data['Image'] ?? '',
        logo: data['Logo'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
        isActive: data['IsActive'] ?? true,
        productCount: int.parse((data['ProductCount'] ?? 0).toString()),
      );
    } else {
      return BrandModel.empty();
    }
  }
} 