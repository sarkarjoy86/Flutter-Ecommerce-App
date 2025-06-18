import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:priyorong/app.dart';
import 'package:priyorong/utils/helpers/network_manager.dart';

import 'data/repositories/authentications/authentication_repository.dart';
import 'firebase_options.dart';

/// Entry point of the Flutter app
Future<void> main() async {
  /// Widgets Binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// Init Local Storage
  await GetStorage.init();

  /// Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Todo: Initialize Network Manager
  // Get.put(NetworkManager());

  /// Initialize Authentication Repository
  Get.put(AuthenticationRepository());

  runApp(const App());
}
