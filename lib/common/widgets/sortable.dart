import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/product_cards/product_card_vertical.dart';

import '../../utils/constants/sizes.dart';
import 'layouts/grid_layout.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown for sorting
        DropdownButtonFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.sort),
          ),
          onChanged: (value) {},
          items: ['Name', 'Higher Price', 'Lower Price', 'Sale', 'Newest', 'Popularity']
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        // Products List
        TGridLayout(
          itemCount: 10,
          itemBuilder: (_, index) => const TProductCardVertical(),
        ),
      ],
    );
  }
}