import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/authentication/screens/signup/widgets/terms_and_conditions.dart';
import 'package:priyorong/utils/validators/validation.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../controllers/signup_controller.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
        key: controller.signupFormKey,
        child: Column(
          children: [
            Row(
              children: [
                /// Name
                Expanded(
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) =>
                        TValidator.validateEmptyText('First Name', value),
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
                    controller: controller.lastName,
                    validator: (value) =>
                        TValidator.validateEmptyText('Last Name', value),
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
              controller: controller.username,
              validator: (value) =>
                  TValidator.validateEmptyText('Username', value),
              expands: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.edit),
                labelText: TTexts.username,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              expands: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct),
                labelText: TTexts.email,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Phone Number
            TextFormField(
              controller: controller.phoneNumber,
              validator: (value) => TValidator.validatePhoneNumber(value),
              expands: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.call),
                labelText: TTexts.phoneNo,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => TValidator.validatePassword(value),
                expands: false,
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(controller.hidePassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye),
                  ), // IconButton
                  labelText: TTexts.password,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Terms and Conditions
            const TermsAndConditions(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign Up Button
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => controller.signup(),
                    child: const Text(TTexts.createAccount))),

            const SizedBox(height: TSizes.spaceBtwItems),
          ],
        ));
  }
}
