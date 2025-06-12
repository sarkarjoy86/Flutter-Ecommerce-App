
import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brand/t_brand_card.dart';
import '../../../../common/widgets/sortable.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';


class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('Nike'),showBackArrow: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Brand Detail
              TBrandCard(title: 'Sultan',
                  image: TImages.clothIcon,
                  productCount: '256 Products',
                  showBorder: true,
                  onTap: () {
                    // Handle tap
                  },),
              const SizedBox(height: TSizes.spaceBtwSections),
              const TSortableProducts(),
            ],
          ),
        ),
      ),
    );
  }
}
