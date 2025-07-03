import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/authentication/screens/verify_emaill.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../navigation_menu.dart';
import 'user_repository.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  // Singleton instance using GetX
  static AuthenticationRepository get instance => Get.find(); //Getter Method

  /// Local storage instance
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;


  /// Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  /// Called from main.dart on app launch
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  ///Register A User
  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw Exception(
          'Something went wrong. Please try again: ${e.toString()}');
    }
  }

  /// Function to show relevant screen
  void screenRedirect() async {
    final user = _auth.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        // Fetch user data for authenticated users before navigating to main app
        try {
          await Get.find<UserController>().fetchUserRecord();
        } catch (e) {
          // Continue even if fetch fails - user can still access the app
          print('Failed to fetch user data during redirect: $e');
        }
        Get.offAll(() => const NavigationMenu());
      } else {
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      // Check if it's the first time. If true, show onboarding; if false, show login
      deviceStorage.read('IsFirstTime') == true
          ? Get.offAll(() => const OnBoardingScreen())
          : Get.offAll(() => const LoginScreen());
    }
  }

  /// [EmailVerification] - MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser
          ?.sendEmailVerification(); // Sending email verification
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code)
          .message; // Handling Firebase Authentication exceptions
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code)
          .message; // Handling general Firebase exceptions
    } on FormatException catch (_) {
      throw const TFormatException(); // Handling format exceptions
    } on PlatformException catch (e) {
      throw TPlatformException(e.code)
          .message; // Handling platform-specific exceptions
    } catch (e) {
      throw 'Something went wrong. Please try again'; // Generic error handling
    }
  }

  /// [LogoutUser] - Valid for any authentication.
  Future<void> logout() async {
    try {
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();
      // Don't navigate here - let the calling controller handle navigation
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      // Handle general Firebase errors
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      // Handle format errors
      throw const TFormatException();
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      throw TPlatformException(e.code);
    } catch (e) {
      // Catch all other errors
      throw 'Something went wrong. Please try again: ${e.toString()}';
    }
  }


  /// [EmailAuthentication] - LOGIN
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication exceptions
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      // Handle general Firebase exceptions
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      // Handle format errors
      throw const TFormatException();
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions (e.g., Android/iOS)
      throw TPlatformException(e.code);
    } catch (e) {
      // Catch any other unexpected errors
      throw 'Something went wrong. Please try again: ${e.toString()}';
    }
  }


  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      // Check if user cancelled the sign-in process
      if (userAccount == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await userAccount.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credentials);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      throw 'Something went wrong. Please try again: ${e.toString()}';
    }
  }


  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [ReAuthenticate] - RE AUTHENTICATE USER
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
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


  /// DELETE USER - Remove user Auth and Firestore Account.
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
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
