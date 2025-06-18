import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:priyorong/bindings/general_bindings.dart';
import 'package:priyorong/features/authentication/screens/onboarding/onboarding.dart';
import 'package:priyorong/utils/constants/colors.dart';
import 'package:priyorong/utils/constants/text_strings.dart';
import 'package:priyorong/utils/theme/theme.dart';

/// Main App Widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      debugShowCheckedModeBanner: false,
      /// Show Loader or Circular Progress Indicator meanwhile Authentication Repository is
      /// deciding to show relevant screen.
      home: const Scaffold (backgroundColor: TColors.primary,
          body: Center(
              child: CircularProgressIndicator (color: Colors.white))),);
  }
}
