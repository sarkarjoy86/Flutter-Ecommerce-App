import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/screens/product_details/product_details.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:priyorong/features/shop/controllers/wishlist_controller.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';
import '../../../utils/constants/colors.dart';
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
  const TProductCardVertical({
    super.key,
    this.product,
  });

  final ProductModel? product;

  // Helper method to get the best available product image
  String _getProductImage() {
    if (product == null) {
      print('❌ Product is null in _getProductImage');
      return '';
    }
    
    final imageUrl = product!.bestDisplayImage;
    
    return imageUrl;
  }
  
  // Helper method to check if image is a network image
  bool _isNetworkImage() {
    final imageUrl = _getProductImage();
    final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    print('🌐 Is network image: $isNetwork for URL: "$imageUrl"');
    return isNetwork;
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();

    // Handle case when product is null (for backward compatibility)
    if (product == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No Product Data'),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product!)),
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
                  Padding(
                    padding: const EdgeInsets.all(TSizes.sm),
                    child: SizedBox(
                      width: double.infinity,
                      height: 140,
                      child: _getProductImage().isNotEmpty
                          ? TRoundedImage(
                              imageUrl: _getProductImage(),
                              applyImageRadius: true,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              isNetworkImage: _isNetworkImage(),
                            )
                          : Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(TSizes.md),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  // Sale Tag - Only show if product is on sale
                  if (product!.isOnSale)
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
                          '${product!.discountPercentage.toInt()}%',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                            color: TColors.black,
                          ),
                        ),
                      ),
                    ),

                  // Favourite Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isInWishlist = wishlistController.isProductInWishlistReactive(product!.id);
                      
                      return TCircularIcon(
                        icon: isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                        color: isInWishlist ? Colors.red : Colors.grey,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        onPressed: () => wishlistController.toggleWishlistItem(product!),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 3),
            // Product Details
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm, right: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(
                    title: product!.title,
                    smallSize: false,
                    maxLines: 2,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),

                  // Brand Row - Only show if brand exists
                  if (product!.brandId != null && product!.brandId!.isNotEmpty)
                    const TBrandTitleWithVerifiedIcon(title: 'Brand'), // You may want to get actual brand name
                ],
              ),
            ),

            const Spacer(),

            // Price & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: TSizes.md),
                  child: Text(
                    '৳${product!.actualPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Quick add to cart functionality
                    final cartController = Get.find<CartController>();
                    await cartController.addToCart(product!, quantity: 1);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red, // Changed to red
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
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}




