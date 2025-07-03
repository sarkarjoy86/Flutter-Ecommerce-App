import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/local_storage/storage_utility.dart';
import '../../../../../utils/popups/loaders.dart';
import '../profile.dart';

class ChangeDateOfBirth extends StatefulWidget {
  const ChangeDateOfBirth({super.key});

  @override
  State<ChangeDateOfBirth> createState() => _ChangeDateOfBirthState();
}

class _ChangeDateOfBirthState extends State<ChangeDateOfBirth> {
  DateTime selectedDate = DateTime(2000, 1, 1);
  final localStorage = TLocalStorage();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved date from local storage
    final savedDate = localStorage.readData<String>('selected_date_of_birth');
    if (savedDate != null) {
      selectedDate = DateTime.parse(savedDate);
    }
    updateDateController();
  }

  void updateDateController() {
    dateController.text = DateFormat('dd MMM, yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Date of Birth', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(
              'Select your date of birth.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Date Picker Field
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Iconsax.calendar),
                suffixIcon: Icon(Iconsax.arrow_down_1),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => saveDateOfBirth(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        updateDateController();
      });
    }
  }

  void saveDateOfBirth() async {
    try {
      // Save to local storage as ISO string
      await localStorage.saveData('selected_date_of_birth', selectedDate.toIso8601String());

      // Show Success Message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Date of birth updated successfully.',
      );

      // Navigate back to profile
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to save date of birth.',
      );
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
} 