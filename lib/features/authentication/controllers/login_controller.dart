import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/repositories/authentications/authentication_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../personalization/controllers/user_controller.dart';
import '../screens/login/login.dart';

class LoginController extends GetxController {
  /// Variables
  final rememberMe = false.obs; // Observable for 'Remember Me' functionality
  final hidePassword = true.obs; // Observable for hiding/showing password
  final localStorage = GetStorage(); // GetStorage instance for local storage
  final email = TextEditingController(); // Controller for email input
  final password = TextEditingController(); // Controller for password input
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>(); // Form key for form validation


  @override
  void onInit() {
    loadSavedCredentials();
    super.onInit();
  }

  /// Load saved credentials from local storage
  void loadSavedCredentials() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    // Set remember me checkbox if credentials exist
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      rememberMe.value = true;
    }
  }


  // --- Email Password Sign in
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Logging you in...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Handle Remember Me functionality
      if (rememberMe.value) {
        // Save credentials if Remember Me is checked
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      } else {
        // Clear saved credentials if Remember Me is unchecked
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
      }

      // Login user using Email & Password Authentication
      final userCredentials = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Refresh user data after successful authentication
      await UserController.instance.fetchUserRecord();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } on TFirebaseAuthException catch (e) {
      TFullScreenLoader.stopLoading();
      // Get user-friendly message based on Firebase error code
      String message = _getLoginErrorMessage(e.message);
      TLoaders.errorSnackBar(
        title: 'Login Failed',
        message: message,
      );
    } on TFirebaseException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Login Failed',
        message: 'Email or password is incorrect. Please check and try again.',
      );
    } on TFormatException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Invalid Format',
        message: 'Please check your email format and try again.',
      );
    } on TPlatformException catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Login Failed',
        message: 'Email or password is incorrect. Please check and try again.',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Login Failed',
        message: 'Email or password is incorrect. Please check and try again.',
      );
    }
  }

  /// LOGOUT METHOD
  Future<void> logout() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Logging you out...', TImages.docerAnimation);

      // Only clear local storage data if Remember Me is not checked
      if (!rememberMe.value) {
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
        // Reset form fields only if not remembering
        email.clear();
        password.clear();
      }
      // Don't reset rememberMe.value to preserve user's preference

      await GoogleSignIn().signOut();
      // Logout user using Authentication Repository
      await AuthenticationRepository.instance.logout();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Wait a bit for the loader to close properly
      await Future.delayed(const Duration(milliseconds: 300));

      // Show Success Message
      TLoaders.successSnackBar(
        title: 'Logged Out',
        message: 'You have been successfully logged out.',
      );

      // Wait for the snackbar to show, then navigate
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to Login Screen after successful logout
      Get.offAll(() => const LoginScreen());

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Error Message
      TLoaders.errorSnackBar(
        title: 'Logout Failed',
        message: e.toString(),
      );
    }
  }

  /// Helper method to get user-friendly error messages for login
  String _getLoginErrorMessage(String errorCode) {
    switch (errorCode.toLowerCase()) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
      case 'user-disabled':
        return 'Email or password is incorrect. Please check and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'operation-not-allowed':
        return 'Login is temporarily disabled. Please contact support.';
      default:
        return 'Email or password is incorrect. Please check and try again.';
    }
  }

  /// -- Google SignIn Authentication
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Logging you in...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'No Internet', 
          message: 'Please check your internet connection and try again.'
        );
        return;
      }

      // Google Authentication
      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();

      // Check if user cancelled Google sign-in
      if (userCredentials == null) {
        TFullScreenLoader.stopLoading();
        return; // User cancelled, do nothing
      }

      // Save user record to Firestore
      await UserController.instance.saveUserRecord(userCredentials);

      // Refresh user data after saving to Firestore
      await UserController.instance.fetchUserRecord();

      // Remove Loader BEFORE navigation
      TFullScreenLoader.stopLoading();

      // Wait a moment for the loader to fully close
      await Future.delayed(const Duration(milliseconds: 300));

      // Redirect after loader is closed
      AuthenticationRepository.instance.screenRedirect();

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Google Sign-In Failed', message: e.toString());
    }
  }



}

