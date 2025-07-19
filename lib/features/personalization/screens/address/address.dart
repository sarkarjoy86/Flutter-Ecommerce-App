import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/personalization/screens/address/single_address.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/address_controller.dart';
import 'add_new_addresses.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add, color: TColors.white),
      ),
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Addresses', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.location,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Addresses Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  'Add your first delivery address by tapping the + button below',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                ...controller.addresses.map((address) => Padding(
                  padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                  child: TSingleAddress(
                    address: address,
                    selectedAddress: address.isSelected,
                    onTap: () => controller.selectAddress(address.id),
                    onDelete: () => _showDeleteDialog(context, controller, address.id),
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(BuildContext context, AddressController controller, String addressId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.deleteAddress(addressId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

