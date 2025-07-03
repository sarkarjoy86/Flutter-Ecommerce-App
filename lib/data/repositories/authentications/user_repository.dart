import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import 'authentication_repository.dart';


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
  Future<UserModel> fetchUserDetails() async {
    try {
      final currentUserUid = AuthenticationRepository.instance.authUser?.uid;
      
      if (currentUserUid == null) {
        return UserModel.empty();
      }

      final documentSnapshot = await _db.collection("Users")
          .doc(currentUserUid)
          .get();
      
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        
        if (data != null && data.isNotEmpty) {
          return UserModel.fromSnapshot(documentSnapshot);
        } else {
          return UserModel.empty();
        }
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again: ${e.toString()}';
    }
  }


// Add the function here to fetch the data.

  /// Function to update user data in Firestore.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toJson());

    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;

    } on FormatException catch (_) {
      throw const TFormatException();

    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;

    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update any field in specific Users Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db.collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);

    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;

    } on FormatException catch (_) {
      throw const TFormatException();

    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;

    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to remove user data from Firestore.
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();

    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;

    } on FormatException catch (_) {
      throw const TFormatException();

    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;

    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to create a basic user record from Firebase Auth data if it doesn't exist
  Future<void> createUserRecordFromAuth() async {
    try {
      final currentUser = AuthenticationRepository.instance.authUser;
      if (currentUser == null) {
        return;
      }

      final docSnapshot = await _db.collection("Users").doc(currentUser.uid).get();
      
      if (!docSnapshot.exists) {
        // Parse display name
        final fullName = currentUser.displayName ?? '';
        final nameParts = fullName.isNotEmpty ? fullName.split(' ') : ['', ''];
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final newUser = UserModel(
          id: currentUser.uid,
          firstName: firstName,
          lastName: lastName,
          username: UserModel.generateUsername(fullName.isNotEmpty ? fullName : currentUser.email?.split('@')[0] ?? ''),
          email: currentUser.email ?? '',
          phoneNumber: currentUser.phoneNumber ?? '',
          profilePicture: currentUser.photoURL ?? '',
        );

        await saveUserRecord(newUser);
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting user experience
    }
  }

  /// Upload any Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

// Add the function here to update user data in Firestore.
}
