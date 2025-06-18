import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/social_buttons.dart';
import 'package:priyorong/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:priyorong/features/authentication/screens/verify_emaill.dart';
import 'package:priyorong/utils/constants/colors.dart';

import '../../../../common/widgets/form_divider.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark =
        THelperFunctions.isDarkMode(context); // Function to check Dark mode
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tile
                Text(TTexts.signupTitle,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Form
                SignupForm(dark: dark),

                /// Divider
                FormDivider(dark: dark),
                const SizedBox(height: TSizes.spaceBtwSections),
                /// Social Button
                const SocialButtons(),
              ],
            )),
      ),
    );
  }
}






