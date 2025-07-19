
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/utils/helpers/helper_functions.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:priyorong/features/shop/controllers/wishlist_controller.dart';
import 'package:priyorong/features/shop/controllers/product_controller.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/curve_edges-widget.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../product_details.dart';


class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();
    final productController = Get.find<ProductController>();
    
    // Prepare images list (display-ready thumbnail + additional images)
    final List<String> productImages = [
      if (product.displayThumbnail.isNotEmpty) product.displayThumbnail,
      ...product.displayImages,
    ];

    return CurvedEdgesWidget(
      child: Container(
        color: dark ? TColors.darkerGrey : TColors.light,
        child: Stack(
          children: [
            /// Main Large Image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.productImageRadius * 2),
                child: Center(
                  child: product.bestDisplayImage.isNotEmpty
                      ? TRoundedImage(
                          imageUrl: product.bestDisplayImage,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          isNetworkImage: product.bestDisplayImage.startsWith('http'),
                        )
                      : Image.asset(
                          TImages.productImage1, // Fallback image
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),

            /// Image Slider Positioned - Only show if there are multiple images
            if (productImages.length > 1)
              Positioned(
                right: 0,
                bottom: 30,
                left: TSizes.defaultSpace,
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    itemCount: productImages.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: TSizes.spaceBtwItems),
                    itemBuilder: (_, index) => TRoundedImage(
                      width: 80,
                      backgroundColor: dark ? TColors.dark : TColors.white,
                      border: Border.all(color: TColors.primary),
                      padding: const EdgeInsets.all(TSizes.sm),
                      imageUrl: productImages[index].isNotEmpty 
                          ? productImages[index] 
                          : TImages.productImage1, // Fallback
                      isNetworkImage: productImages[index].startsWith('http'),
                    ),
                  ),
                ),
              ),

            /// Appbar Icons (no reload button needed)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TAppBar(
                showBackArrow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}