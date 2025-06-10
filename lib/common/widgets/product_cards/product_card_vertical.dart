import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/screens/product_details/product_details.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/shadows.dart';
import '../circular_container_shape.dart';
import '../icons/t_circular_icon.dart';
import '../images/t_rounded_image.dart';
import '../texts/brandTitleWithvarified_icon.dart';
import '../texts/product_price_text.dart';
import '../texts/product_title_text.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail, Wishlist Button, Discount Tag
            CircularContainer(
              height: 160,
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  // Thumbnail Image - Full width
                  const Padding(
                    padding: EdgeInsets.all(TSizes.sm),
                    child: TRoundedImage(
                      imageUrl: TImages.productImage1,
                      applyImageRadius: true,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Sale Tag
                  Positioned(
                    top: 12,
                    left: 8,
                    child: CircularContainer(
                      radius: TSizes.sm,
                      backgroundColor: Colors.yellow.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.sm,
                        vertical: TSizes.xs,
                      ),
                      child: Text(
                        '25%',
                        style: Theme.of(context).textTheme.labelLarge!.apply(
                          color: TColors.black,
                        ),
                      ),
                    ),
                  ),

                  // Favourite Icon
                  const Positioned(
                    top: 8,
                    right: 8,
                    child:
                    TCircularIcon(icon: Iconsax.heart5, color: Colors.red,),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 3),
            // Product Details
            const Padding(
              padding: EdgeInsets.only(left: TSizes.sm, right: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(
                    title: 'Khadi Panjabi',
                    smallSize: false,
                    maxLines: 2,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems / 2),

                  // Brand Row
                  TBrandTitleWithVerifiedIcon(title: 'Sultan'),
                ],
              ),
            ),

            const Spacer(),

            // Price & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: TSizes.md),
                  child: TProductPriceText(
                    price: '650',
                    isLarge: false,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: TColors.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(TSizes.cardRadiusMd),
                      bottomRight:
                      Radius.circular(TSizes.productImageRadius),
                    ),
                  ),
                  child: const SizedBox(
                    width: TSizes.iconLg * 1.2,
                    height: TSizes.iconLg * 1.2,
                    child: Center(
                      child: Icon(Iconsax.add, color: TColors.white),
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




