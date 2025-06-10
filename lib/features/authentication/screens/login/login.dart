import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/utils/constants/colors.dart';
import 'package:priyorong/utils/constants/sizes.dart';
import 'package:priyorong/utils/constants/text_strings.dart';
import 'package:priyorong/utils/helpers/helper_functions.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../common/widgets/social_buttons.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark =
        THelperFunctions.isDarkMode(context); // Function to check Dark mode
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyles.paddingwithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title , subtitle
              LoginHeader(dark: dark),

              /// Form
              const LoginForm(),

              /// Divider
              FormDivider(dark: dark),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Footer
              const SocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class FormDivider extends StatelessWidget {
  const FormDivider({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
            child: Divider(
          color: dark ? TColors.darkerGrey : TColors.grey,
          thickness: 0.5,
          indent: 60,
          endIndent: 5,
        )),
        Text(TTexts.orSignInWith.capitalize!,
            style: Theme.of(context).textTheme.labelMedium),
        Flexible(
            child: Divider(
          color: dark ? TColors.darkerGrey : TColors.grey,
          thickness: 0.5,
          indent: 5,
          endIndent: 60,
        )),
      ],
    );
  }
}




