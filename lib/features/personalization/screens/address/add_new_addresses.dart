import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/address_controller.dart';
import '../../models/address_model.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key, this.addressToEdit});

  final AddressModel? addressToEdit;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();
    final isEditing = addressToEdit != null;

    // Fill form if editing
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fillFormForEdit(addressToEdit!);
      });
    }

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(isEditing ? 'Edit Address' : 'Add new Address'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Phone Number Field
                TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Street Address & Postcode Fields in Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.streetController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building_31),
                          labelText: 'Street',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.postcodeController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postcode',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // City & State Fields in Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.cityController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'City',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.stateController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'State',
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Country Field
                TextFormField(
                  controller: controller.countryController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Save Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () {
                            if (isEditing) {
                              controller.updateAddress(addressToEdit!);
                            } else {
                              controller.addAddress();
                            }
                          },
                    child: controller.isLoading.value 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Update Address' : 'Save Address'),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
