import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';

class AuthenticationRepository extends GetxController {
  // Singleton instance using GetX
  static AuthenticationRepository get instance => Get.find(); //Getter Method

  /// Local storage instance
  final deviceStorage = GetStorage();

  /// Called from main.dart on app launch
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }


  /// Function to show relevant screen
  void screenRedirect() async {
    deviceStorage.writeIfNull('IsFirstTime', true);
    // Check if it's the first time. If true, show onboarding; if false, show login
    deviceStorage.read('IsFirstTime') == true 
        ? Get.offAll(() => const OnBoardingScreen()) 
        : Get.offAll(() => const LoginScreen());
  }

/*
    ─────────────────────────────────────────────────────────────────────
    Authentication Flow Notes:
    - ReAuthenticate User: [ReAuthenticate]
    - Email & Password Sign-In: [EmailAuthentication] SignIn
    - Register New User: [EmailAuthentication] REGISTER
    - Email Verification: [EmailVerification] MAIL VERIFICATION
    - Forgot Password: [EmailAuthentication] FORGET PASSWORD
  */
}
