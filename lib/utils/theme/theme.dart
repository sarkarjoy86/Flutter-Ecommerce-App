import 'package:flutter/material.dart';
import 'package:priyorong/utils/theme/widget_themes/appbar_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/chip_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/text_field_theme.dart';
import 'package:priyorong/utils/theme/widget_themes/text_theme.dart';

import '../constants/colors.dart';

//Custom Class for Themes
class TAppTheme {
  TAppTheme._(); //Constructor

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,  // Latest Material Design System
    fontFamily: 'Poppins',
    disabledColor: TColors.grey,
    brightness: Brightness.light, //Actual Light Theme
    primaryColor: TColors.primary,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    scaffoldBackgroundColor: TColors.white,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );   //Light Theme Function

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Latest Material Design System
    fontFamily: 'Poppins',
    disabledColor: TColors.grey,
    brightness: Brightness.dark, // Actual Dark Theme
    primaryColor: TColors.primary,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    scaffoldBackgroundColor: TColors.black,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  ); // Dark Theme Function
}
