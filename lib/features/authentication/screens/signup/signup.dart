import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/social_buttons.dart';
import 'package:priyorong/features/authentication/screens/verify_emaill.dart';
import 'package:priyorong/utils/constants/colors.dart';

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
            padding: EdgeInsets.all(TSizes.defaultSpace),
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

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        Row(
          children: [
            /// Name
            Expanded(
              child: TextFormField(
                expands: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.user),
                  labelText: TTexts.firstName,
                ),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwInputFields),
            Expanded(
              child: TextFormField(
                expands: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.user),
                  labelText: TTexts.lastName,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),

        /// Username
        TextFormField(
          expands: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.edit),
            labelText: TTexts.username,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),

        /// Email
        TextFormField(
          expands: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.direct),
            labelText: TTexts.email,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),

        /// Phone Number
        TextFormField(
          expands: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.call),
            labelText: TTexts.phoneNo,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),

        /// Password
        TextFormField(
          expands: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.password_check),
            suffixIcon: Icon(Iconsax.eye_slash),
            labelText: TTexts.password,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        /// Terms and Conditions
        TermsAndConditions(dark: dark),
        const SizedBox(height: TSizes.spaceBtwSections),

        /// Sign Up Button
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => Get.to(() => const VerifyEmailScreen()),
                child: const Text(TTexts.createAccount))),

        const SizedBox(height: TSizes.spaceBtwItems),
      ],
    ));
  }
}

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 24,
            height: 24,
            child:
                Checkbox(value: true, onChanged: (value) {})),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(TextSpan(
          children: [
            TextSpan(
                text: '${TTexts.iAgreeTo} ',
                style: Theme.of(context).textTheme.bodySmall),
            TextSpan(
                text: '${TTexts.privacyPolicy} ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(
                      color: dark
                          ? TColors.white
                          : TColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: dark
                          ? TColors.white
                          : TColors.primary,
                    )),
            TextSpan(
                text: '${TTexts.and} ',
                style: Theme.of(context).textTheme.bodySmall),
            TextSpan(
                text: '${TTexts.termsOfUse} ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(
                      color: dark
                          ? TColors.white
                          : TColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: dark
                          ? TColors.white
                          : TColors.primary,
                    ))
          ],
        ))
      ],
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
        Text(TTexts.orSignUpWith.capitalize!,
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
