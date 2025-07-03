import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/chnage_name.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/change_phone_number.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/change_gender.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/change_date_of_birth.dart';
import 'package:priyorong/features/personalization/screens/profile/widgets/profile_menu.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/local_storage/storage_utility.dart';
import '../../../authentication/controllers/login_controller.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildGenderMenu() {
    final localStorage = TLocalStorage();
    final savedGender = localStorage.readData<String>('selected_gender') ?? 'Male';
    
    return TProfileMenu(
      title: 'Gender',
      value: savedGender,
      onPressed: () => Get.to(() => const ChangeGender()),
    );
  }

  Widget _buildDateOfBirthMenu() {
    final localStorage = TLocalStorage();
    final savedDate = localStorage.readData<String>('selected_date_of_birth');
    
    String displayDate = '26 May, 2002'; // Default value
    if (savedDate != null) {
      try {
        final date = DateTime.parse(savedDate);
        displayDate = DateFormat('dd MMM, yyyy').format(date);
      } catch (e) {
        // Use default if parsing fails
      }
    }
    
    return TProfileMenu(
      title: 'Date of Birth',
      value: displayDate,
      onPressed: () => Get.to(() => const ChangeDateOfBirth()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
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
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty? networkImage: TImages.user;
                      return TCircularImage(
                        image: image,
                        width: 80,
                        height: 80,
                          isNetworkImage: networkImage.isNotEmpty,
                      );
                    },
                    ),
                    TextButton(
                      onPressed: () =>
                          controller.uploadUserProfilePicture(),
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

              Obx(() => TProfileMenu(
                  title: 'Name',
                  value: controller.user.value.fullName,
                  onPressed: () => Get.to(() => const ChangeName()))),
              Obx(() => TProfileMenu(
                  title: 'Username',
                  value: controller.user.value.username,
                  icon: Iconsax.copy,
                  onPressed: () {})),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading: Personal Info
              const TSectionHeading(
                  title: 'Personal Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() => TProfileMenu(
                  title: 'User ID',
                  value: controller.user.value.id,
                  icon: Iconsax.copy,
                  onPressed: () {})),
              Obx(() => TProfileMenu(
                  title: 'E-mail',
                  value: controller.user.value.email,
                  onPressed: () {})),
              Obx(() => TProfileMenu(
                  title: 'Phone NO.',
                  value: controller.user.value.phoneNumber,
                  onPressed: () => Get.to(() => const ChangePhoneNumber()))),
              _buildGenderMenu(),
              _buildDateOfBirthMenu(),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Logout Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.logoutConfirmationPopup(),
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
                    onPressed: () =>
                        controller.deleteAccountWarningPopup(),
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
