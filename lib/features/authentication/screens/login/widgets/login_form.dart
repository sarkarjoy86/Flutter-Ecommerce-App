import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/authentication/password_configuration/forget_password.dart';
import 'package:priyorong/features/authentication/screens/signup/signup.dart';
import 'package:priyorong/navigation_menu.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/login_controller.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
        key: controller.loginFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
          child: Column(
            children: [
              /// Email
              TextFormField(
                controller: controller.email,
                // Controller for the email input field
                validator: (value) => TValidator.validateEmail(value),
                // Custom email validator
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.direct_right),
                  labelText: TTexts.email,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              ///Password
              Obx(
                () => TextFormField(
                  controller: controller.password,
                  validator: (value) => TValidator.validateLoginPassword(value),
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
              const SizedBox(height: TSizes.spaceBtwInputFields / 2),

              /// Remember me and Forget PassWord
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Remember Me
                  Row(
                    children: [
                      Obx(() => Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: (value) => controller.rememberMe.value =
                              !controller.rememberMe.value)),
                      const Text(TTexts.rememberMe),
                    ],
                  ),

                  /// Forget Password
                  TextButton(
                      onPressed: () => Get.to(() => const ForgetPassword()),
                      child: const Text(TTexts.forgetPassword)),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Sign in
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => controller.emailAndPasswordSignIn(),
                      child: const Text(TTexts.signIn))),

              const SizedBox(height: TSizes.spaceBtwItems),

              /// Create Account Button
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () => Get.to(() => const SignupScreen()),
                      child: const Text(TTexts.createAccount))),
            ],
          ),
        ));
  }
}
