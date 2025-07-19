import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:priyorong/features/shop/controllers/wishlist_controller.dart';
import 'package:priyorong/features/shop/controllers/review_controller.dart';

import '../../../../../utils/constants/sizes.dart';


class TRatingAndShare extends StatelessWidget {
  const TRatingAndShare({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final reviewController = Get.find<ReviewController>();
    final stats = reviewController.reviewStatistics.value;
    final showDynamic = reviewController.reviews.isNotEmpty && reviewController.reviews.first.productId == product.id;
    final rating = showDynamic ? stats.averageRating : product.rating;
    final reviewCount = showDynamic ? stats.totalReviews : product.reviewCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Rating
        Row(
          children: [
            const Icon(Iconsax.star5, color: Colors.amber, size: 24),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(text: ' ($reviewCount)'),
                ],
              ),
            ),
          ],
        ),

        /// Actions - Wishlist and Share
        Row(
          children: [
            // Wishlist Button with visual feedback
            Obx(() {
              final isInWishlist = wishlistController.isProductInWishlistReactive(product.id);
              
              return IconButton(
                onPressed: () => wishlistController.toggleWishlistItem(product),
                icon: Icon(
                  isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                  color: isInWishlist ? Colors.red : Colors.grey,
                  size: TSizes.iconMd,
                ),
              );
            }),
            
            /// Share Button
            IconButton(
              onPressed: () {
                // TODO: Implement share functionality
                // You can use share_plus package here
              },
              icon: const Icon(Icons.share, size: TSizes.iconMd),
            ),
          ],
        ),
      ],
    );
  }
}
