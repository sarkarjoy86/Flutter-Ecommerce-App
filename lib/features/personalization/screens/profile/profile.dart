import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/profile_menu.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/login_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    
    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Profile'),
      ),
      // -- Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const TCircularImage(
                      image: TImages.user,
                      width: 80,
                      height: 80,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details

              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading: Profile Info
              const TSectionHeading(
                  title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                  title: 'Name', value: 'Joy Sarkar', onPressed: () {}),
              TProfileMenu(
                  title: 'Username',
                  value: 'sarkarjoy86',
                  icon: Iconsax.copy,
                  onPressed: () {}),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading: Personal Info
              const TSectionHeading(
                  title: 'Personal Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                  title: 'User ID',
                  value: '818291',
                  icon: Iconsax.copy,
                  onPressed: () {}),
              TProfileMenu(
                  title: 'E-mail',
                  value: 'joysarkar1086@gmail.com',
                  onPressed: () {}),
              TProfileMenu(
                  title: 'Phone NO.',
                  value: '+8801992-487980',
                  onPressed: () {}),
              TProfileMenu(title: 'Gender', value: 'Male', onPressed: () {}),
              TProfileMenu(
                  title: 'Date of Birth',
                  value: '26 May, 2002',
                  onPressed: () {}),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              /// Logout Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => loginController.logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      side: const BorderSide(color: TColors.primary),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              /// Close Account Button
              Center(
                child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Close Account',
                      style: TextStyle(color: TColors.primary),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
