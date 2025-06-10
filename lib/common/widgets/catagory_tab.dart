import 'package:flutter/material.dart';
import 'package:priyorong/common/widgets/layouts/grid_layout.dart';
import 'package:priyorong/common/widgets/product_cards/product_card_vertical.dart';
import 'package:priyorong/common/widgets/section_heading.dart';

import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import 'brand/brand_showcase.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Brands
              const TBrandShowcase(
                images: [
                  TImages.productImage1,
                  TImages.productImage1,
                  TImages.productImage1
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Products
              TSectionHeading(title: 'You Might Like', onPressed: () {}),
              const SizedBox(height: TSizes.spaceBtwItems),
              TGridLayout(
                  itemCount: 4,
                  itemBuilder: (_, index) => const TProductCardVertical())
            ],
          ),
        ),
      ],
    );
  }
}
