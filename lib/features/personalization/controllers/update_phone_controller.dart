import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authentications/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../screens/profile/profile.dart';
import 'user_controller.dart';

/// Controller to manage user phone number updates.
class UpdatePhoneController extends GetxController {
  static UpdatePhoneController get instance => Get.find();

  final phoneNumber = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updatePhoneFormKey = GlobalKey<FormState>();

  /// Init user data when Home Screen appears
  @override
  void onInit() {
    initializePhoneNumber();
    super.onInit();
  }

  /// Fetch user record
  Future<void> initializePhoneNumber() async {
    phoneNumber.text = userController.user.value.phoneNumber;
  }

  Future<void> updatePhoneNumber() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('We are updating your information...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updatePhoneFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update user's phone number in the Firebase Firestore
      Map<String, dynamic> phone = {
        'PhoneNumber': phoneNumber.text.trim(),
      };
      await userRepository.updateSingleField(phone);

      // Update the Rx User value and trigger reactive update
      final updatedUser = userController.user.value;
      updatedUser.phoneNumber = phoneNumber.text.trim();
      userController.user.value = updatedUser;
      userController.user.refresh(); // Trigger UI update

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(title: 'Congratulations', message: 'Your Phone Number has been updated.');

      // Move to previous screen.
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
} 