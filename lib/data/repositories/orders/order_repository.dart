import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/order_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  // Variables
  final _db = FirebaseFirestore.instance;

  // Create new order
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _db.collection('Orders').add(order.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get user's orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection('Orders')
          .where('UserId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Get single order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final doc = await _db.collection('Orders').doc(orderId).get();
      
      if (doc.exists) {
        return OrderModel.fromSnapshot(doc);
      } else {
        throw 'Order not found';
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updateData = {
        'Status': status.name,
      };

      await _db.collection('Orders').doc(orderId).update(updateData);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
} 