import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  // Variables
  final _db = FirebaseFirestore.instance;

  // Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db
          .collection('Brands')
          .where('IsActive', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return [];
      }
      
      final list = snapshot.docs
          .map((document) => BrandModel.fromSnapshot(document))
          .toList();
      
      return list;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get featured brands
  Future<List<BrandModel>> getFeaturedBrands() async {
    try {
      final snapshot = await _db
          .collection('Brands')
          .where('IsFeatured', isEqualTo: true)
          .where('IsActive', isEqualTo: true)
          .limit(8)
          .get();
      
      return snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get single brand by ID
  Future<BrandModel> getBrandById(String brandId) async {
    try {
      final doc = await _db.collection('Brands').doc(brandId).get();
      
      if (doc.exists) {
        return BrandModel.fromSnapshot(doc);
      } else {
        throw 'Brand not found';
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Add brand (for admin)
  Future<String> addBrand(BrandModel brand) async {
    try {
      final docRef = await _db.collection('Brands').add(brand.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update brand (for admin)
  Future<void> updateBrand(String brandId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Brands').doc(brandId).update(data);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Delete brand (for admin)
  Future<void> deleteBrand(String brandId) async {
    try {
      await _db.collection('Brands').doc(brandId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update brand product count
  Future<void> updateBrandProductCount(String brandId, int productCount) async {
    try {
      await _db.collection('Brands').doc(brandId).update({
        'ProductCount': productCount,
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
} 