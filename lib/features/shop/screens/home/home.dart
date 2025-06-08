import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/home_Categories.dart';
import 'package:priyorong/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:priyorong/utils/constants/colors.dart';
import 'package:priyorong/utils/constants/sizes.dart';
import 'package:priyorong/utils/device/device_utility.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/cart_menu_icon.dart';
import '../../../../common/widgets/circular_container_shape.dart';
import '../../../../common/widgets/curve_edges-widget.dart';
import '../../../../common/widgets/curved_edges.dart';
import '../../../../common/widgets/home_appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/t_rounded_image.dart';
import '../../../../common/widgets/vertical_image_text_widgets.dart';
import '../../../../common/widgets/primary_header_container.dart';
import '../../../../common/widgets/search_bar.dart';
import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PrimaryHeaderContainer(
              child: Column(
                children: [
                  THomeAppbar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// Searchbar
                  TSearchContainer(
                    text: 'Search in Stores',
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// Categories
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        TSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: TSizes.spaceBtwItems),

                        /// Categories List
                        THome_Categories(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),

              child: Column(
                children: [
                  const THomeSlider(),
                  const SizedBox(height: TSizes.spaceBtwSections),


                  /// Heading
                  TSectionHeading(title: 'Popular Products', onPressed: () {}),
                  /// Popular Products
                  TGridLayout(itemCount: 4, itemBuilder: (_, index) => const TProductCardVertical()),

                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}




