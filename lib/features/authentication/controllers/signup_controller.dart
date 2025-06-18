import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../screens/verify_emaill.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables for controllers and form key
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
  Future<void> signup() async {
    try {
      // Form Validation - Check this FIRST before loading
      if (!signupFormKey.currentState!.validate()) {
        TLoaders.warningSnackBar(
          title: 'Validation Failed',
          message: 'Please fill in all required fields correctly.',
        );
        return;
      }

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.warningSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
        );
        return;
      }

      // Start Loading only after validation passes
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information...', TImages.docerAnimation);

      // TODO: Add your signup logic here (Firebase Auth, etc.)
      
      // For now, just simulate some processing
      await Future.delayed(Duration(seconds: 2));

    } catch (e) {
      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      // Remove Loader
      TFullScreenLoader.stopLoading();
    }
  }

  // Dummy method to simulate internet connectivity check
  Future<bool> _checkInternetConnectivity() async {
    // You can implement this with a package like 'connectivity' to check the actual network status
    await Future.delayed(Duration(seconds: 1)); // Simulate network check
    return true; // Assume connected
  }
}
