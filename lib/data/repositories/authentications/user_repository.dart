import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';


// Repository class for user-related operations
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      print("Attempting to save user to Firestore...");
      print("Collection: Users, Document ID: ${user.id}");
      print("Data to save: ${user.toJson()}");
      
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      print("Current authenticated user: ${currentUser.uid}");
      
      // Use merge: true to avoid overwriting existing data and handle permissions better
      await _db.collection("Users").doc(user.id).set(user.toJson(), SetOptions(merge: true));
      print("User data successfully saved to Firestore");
    } on FirebaseException catch (e) {
      print("FirebaseException in saveUserRecord: ${e.code} - ${e.message}");
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Please check Firestore security rules');
      }
      throw TFirebaseException(e.code);
    } on FormatException catch (e) {
      print("FormatException in saveUserRecord: $e");
      throw const TFormatException();
    } on PlatformException catch (e) {
      print("PlatformException in saveUserRecord: ${e.code} - ${e.message}");
      throw TPlatformException(e.code);
    } catch (e) {
      print("Unknown exception in saveUserRecord: $e");
      throw Exception('Something went wrong saving user data: ${e.toString()}');
    }
  }

/// Function to fetch user details based on user ID.
// Add the function here to fetch the data.

/// Function to update user data in Firestore.
// Add the function here to update user data in Firestore.
}
