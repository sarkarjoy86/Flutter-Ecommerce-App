import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/controllers/wishlist_controller.dart';
import 'package:priyorong/features/shop/controllers/product_controller.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../utils/constants/sizes.dart';
import '../home/home.dart';


class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final productController = Get.find<ProductController>();
    
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: false,
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TCircularIcon(
            icon: Iconsax.add,
            onPressed: () => Get.to(const HomeScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Obx(() {
                if (wishlistController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final wishlistItems = wishlistController.wishlistItems;
                
                if (wishlistItems.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 100),
                        Icon(
                          Iconsax.heart,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your wishlist is empty',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add products to your wishlist to see them here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Get actual products for wishlist items
                final wishlistProducts = productController.allProducts
                    .where((product) => wishlistItems.any((item) => item.productId == product.id))
                    .toList();
                
                return TGridLayout(
                  itemCount: wishlistProducts.length,
                  itemBuilder: (_, index) => TProductCardVertical(
                    product: wishlistProducts[index],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
