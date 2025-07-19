import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../models/address_model.dart';

class TSingleAddress extends StatelessWidget {
  const TSingleAddress({
    super.key, 
    required this.address,
    required this.selectedAddress,
    this.onTap,
    this.onDelete,
  });

  final AddressModel address;
  final bool selectedAddress;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: CircularContainer(
        showBorder: true,
        padding: const EdgeInsets.all(TSizes.md),
        width: double.infinity,
        backgroundColor: selectedAddress ? TColors.primary.withOpacity(0.3) : Colors.transparent,
        borderColor: selectedAddress ? TColors.primary : Colors.grey.withOpacity(0.3),
        child: Stack(
          children: [
            // Selected indicator
            Positioned(
              right: 5,
              top: 0,
              child: Icon(
                selectedAddress ? Iconsax.tick_circle5 : null,
                color: selectedAddress
                    ? dark
                    ? TColors.light
                    : TColors.dark.withOpacity(0.6)
                    : null,
              ),
            ),
            
            // Delete button (only show on non-selected addresses)
            if (!selectedAddress && onDelete != null)
              Positioned(
                right: 35,
                top: 0,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Iconsax.trash,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
            
            // Address content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TSizes.sm / 2),
                Text(
                  address.phoneNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: TSizes.sm / 2),
                Text(
                  address.formattedAddress,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                // Selection hint
                if (!selectedAddress)
                  Container(
                    margin: const EdgeInsets.only(top: TSizes.sm),
                    child: Text(
                      'Tap to select as delivery address',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
