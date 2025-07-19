import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    this.parentId = '',
  });

  // Empty Helper Function
  static CategoryModel empty() => CategoryModel(id: '', image: '', name: '', isFeatured: false);

  // Convert model to JSON structure so that you can store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Image': image,
      'ParentId': parentId,
      'IsFeatured': isFeatured,
    };
  }

  // Map JSON oriented document snapshot from Firebase to CategoryModel
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Handle null ParentId from Firebase (null becomes empty string)
      String parentId = '';
      final parentIdField = data['ParentId'];
      if (parentIdField != null && parentIdField.toString().toLowerCase() != 'null') {
        parentId = parentIdField.toString();
      }

      // Map JSON Record to the Model
      final category = CategoryModel(
        id: document.id,
        name: data['Name']?.toString() ?? '',
        image: data['Image']?.toString() ?? '',
        parentId: parentId,
        isFeatured: data['IsFeatured'] == true,
      );
      
      return category;
    } else {
      return CategoryModel.empty();
    }
  }
}
