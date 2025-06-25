import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authentications/authentication_repository.dart';
import '../../../data/repositories/authentications/user_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../models/user_model.dart';
import '../screens/verify_emaill.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables for controllers and form key
  final hidePassword = true.obs; // Observable for hiding/showing password
  final privacyPolicy = true.obs; // Observable for hiding/showing password
  final email = TextEditingController(); // Controller for email input
  final lastName = TextEditingController(); // Controller for last name input
  final username = TextEditingController(); // Controller for username input
  final password = TextEditingController(); // Controller for password input
  final firstName = TextEditingController(); // Controller for first name input
  final phoneNumber =
      TextEditingController(); // Controller for phone number input

  /// Form key for form validation
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  /// SIGNUP METHOD
  void signup() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information...',
          'assets/images/animations/110052-paper-plane.json');

      // Form Validation - Check this FIRST before loading
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check Internet Connectivity - Temporarily disabled to isolate issue
      // final networkManager = NetworkManager();
      // final isConnected = await networkManager.isConnected();
      // if (!isConnected) {
      //   TFullScreenLoader.stopLoading();
      //   TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection and try again.');
      //   return;
      // }

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message:
              'In order to create account, you must have to read and accept the Privacy Policy & Terms of Use.',
        );
        return;
      }

      // Register user in Firebase Authentication & Save user data in Firebase
      print("Starting Firebase Authentication...");
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());
      print(
          "Firebase Authentication successful. User ID: ${userCredential.user!.uid}");

      // Wait a moment for authentication state to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      // Save Authenticated user data in Firebase Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
      );
      print("UserModel created: ${newUser.toJson()}");

      // Save user data to Firestore - with separate try-catch
      try {
        print("Starting Firestore save...");
        final userRepository = Get.put(UserRepository());
        await userRepository.saveUserRecord(newUser);
        print("Firestore save successful!");
      } catch (firestoreError) {
        print("Firestore save failed: $firestoreError");
        // Even if Firestore save fails, we still proceed since auth was successful
        // We can show a warning but don't block the user flow
        TLoaders.warningSnackBar(
            title: 'Profile Save Warning',
            message:
                'Account created but profile data save failed. Please update your profile later.');
      }

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your account has been created! Verify email to continue.');

      // Move to Verify Email Screen
      Get.to(() => const VerifyEmailScreen());
    } on TFirebaseAuthException catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Firebase Auth Error to the user
      TLoaders.errorSnackBar(title: 'Authentication Error', message: e.message);
    } on TFirebaseException catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Firebase Error to the user
      TLoaders.errorSnackBar(title: 'Firebase Error', message: e.message);
    } on TFormatException catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Format Error to the user
      TLoaders.errorSnackBar(title: 'Format Error', message: e.message);
    } on TPlatformException catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Platform Error to the user
      TLoaders.errorSnackBar(title: 'Platform Error', message: e.message);

      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim(),));

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
