import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/product_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  // Variables
  final _db = FirebaseFirestore.instance;

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      print('🔄 Repository: Querying Products collection...');
      final snapshot = await _db.collection('Products').where('IsActive', isEqualTo: true).get();
      
      print('📊 Repository: Found ${snapshot.docs.length} documents in Products collection');
      
      if (snapshot.docs.isEmpty) {
        print('⚠️ Repository: No products found');
        return [];
      }
      
      final list = snapshot.docs
          .map((document) => ProductModel.fromQuerySnapshot(document))
          .toList();
      
      print('✅ Repository: Successfully parsed ${list.length} products');
      return list;
    } on FirebaseException catch (e) {
      print('❌ Repository Firebase Error: ${e.code} - ${e.message}');
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      print('❌ Repository Platform Error: ${e.code} - ${e.message}');
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('❌ Repository General Error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  // Get featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      print('🔄 Repository: Querying Featured Products...');
      final snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .where('IsActive', isEqualTo: true)
          .limit(8)
          .get();
      
      print('📊 Repository: Found ${snapshot.docs.length} featured products');
      
      final products = snapshot.docs.map((doc) => ProductModel.fromQuerySnapshot(doc)).toList();
      print('✅ Repository: Successfully parsed ${products.length} featured products');
      
      return products;
    } on FirebaseException catch (e) {
      print('❌ Repository Featured Firebase Error: ${e.code} - ${e.message}');
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      print('❌ Repository Featured Platform Error: ${e.code} - ${e.message}');
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('❌ Repository Featured General Error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId, {int? limit}) async {
    try {
      QuerySnapshot snapshot;
      
      if (limit != null) {
        snapshot = await _db
            .collection('Products')
            .where('CategoryId', isEqualTo: categoryId)
            .where('IsActive', isEqualTo: true)
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection('Products')
            .where('CategoryId', isEqualTo: categoryId)
            .where('IsActive', isEqualTo: true)
            .get();
      }
      
      return snapshot.docs.map((doc) => ProductModel.fromQuerySnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get products by brand
  Future<List<ProductModel>> getProductsByBrand(String brandId, {int? limit}) async {
    try {
      QuerySnapshot snapshot;
      
      if (limit != null) {
        snapshot = await _db
            .collection('Products')
            .where('BrandId', isEqualTo: brandId)
            .where('IsActive', isEqualTo: true)
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection('Products')
            .where('BrandId', isEqualTo: brandId)
            .where('IsActive', isEqualTo: true)
            .get();
      }
      
      return snapshot.docs.map((doc) => ProductModel.fromQuerySnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get single product by ID
  Future<ProductModel> getProductById(String productId) async {
    try {
      final doc = await _db.collection('Products').doc(productId).get();
      
      if (doc.exists) {
        return ProductModel.fromSnapshot(doc);
      } else {
        throw 'Product not found';
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where('IsActive', isEqualTo: true)
          .get();
      
      // Filter products based on title containing the query
      final filteredProducts = snapshot.docs
          .map((doc) => ProductModel.fromQuerySnapshot(doc))
          .where((product) => product.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return filteredProducts;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get products with pagination
  Future<List<ProductModel>> getProductsPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? categoryId,
    String? brandId,
  }) async {
    try {
      Query query = _db
          .collection('Products')
          .where('IsActive', isEqualTo: true)
          .limit(limit);

      if (categoryId != null) {
        query = query.where('CategoryId', isEqualTo: categoryId);
      }

      if (brandId != null) {
        query = query.where('BrandId', isEqualTo: brandId);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => ProductModel.fromQuerySnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Add product (for admin)
  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _db.collection('Products').add(product.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update product (for admin)
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Products').doc(productId).update(data);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Delete product (for admin)
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('Products').doc(productId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update product rating
  Future<void> updateProductRating(String productId, double newRating, int newReviewCount) async {
    try {
      await _db.collection('Products').doc(productId).update({
        'Rating': newRating,
        'ReviewCount': newReviewCount,
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _db.collection('Products').doc(productId).update({
        'Stock': newStock,
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Reduce product stock after order
  Future<void> reduceProductStock(String productId, int quantity) async {
    final docRef = _db.collection('Products').doc(productId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final currentStock = (snapshot.data()?['Stock'] ?? 0) as int;
      final newStock = (currentStock - quantity).clamp(0, currentStock);
      transaction.update(docRef, {'Stock': newStock});
    });
  }

  // Test Firebase connection
  Future<QuerySnapshot> testFirebaseConnection() async {
    return await _db.collection('Products').limit(1).get();
  }

  // Get all products without filtering (for debugging)
  Future<QuerySnapshot> getAllProductsRaw() async {
    return await _db.collection('Products').get();
  }
} 