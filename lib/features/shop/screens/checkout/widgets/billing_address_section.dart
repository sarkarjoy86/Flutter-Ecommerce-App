import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/address_controller.dart';
import '../../../../personalization/screens/address/address.dart';

class TBillingAddressSection extends StatelessWidget {
  const TBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    
    return Obx(() {
      final selectedAddress = addressController.selectedAddress.value;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TSectionHeading(
            title: 'Shipping Address',
            buttonTitle: selectedAddress != null ? 'Change' : 'Add',
            onPressed: () => Get.to(() => const UserAddressScreen()),
          ),
          
          if (selectedAddress != null) ...[
            // Name
            Text(
              selectedAddress.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            
            // Phone
            Row(
              children: [
                const Icon(
                  Iconsax.call,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(
                  selectedAddress.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            
            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.location,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Text(
                    selectedAddress.formattedAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ] else ...[
            // No address selected
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    Iconsax.location_add,
                    color: Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    'No shipping address selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: TSizes.xs),
                  Text(
                    'Please add a delivery address to continue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}
