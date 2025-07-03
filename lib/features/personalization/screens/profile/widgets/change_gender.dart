import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/local_storage/storage_utility.dart';
import '../../../../../utils/popups/loaders.dart';
import '../profile.dart';

class ChangeGender extends StatefulWidget {
  const ChangeGender({super.key});

  @override
  State<ChangeGender> createState() => _ChangeGenderState();
}

class _ChangeGenderState extends State<ChangeGender> {
  String selectedGender = 'Male';
  final localStorage = TLocalStorage();

  @override
  void initState() {
    super.initState();
    // Load saved gender from local storage
    selectedGender = localStorage.readData<String>('selected_gender') ?? 'Male';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Gender', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(
              'Select your gender preference.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Gender Options
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                    secondary: const Icon(Iconsax.man),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                    secondary: const Icon(Iconsax.woman),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Prefer not to say'),
                    value: 'Prefer not to say',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                    secondary: const Icon(Iconsax.user),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => saveGender(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveGender() async {
    try {
      // Save to local storage
      await localStorage.saveData('selected_gender', selectedGender);

      // Show Success Message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Gender preference updated successfully.',
      );

      // Navigate back to profile
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to save gender preference.',
      );
    }
  }
} 