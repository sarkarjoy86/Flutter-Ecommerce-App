import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';

import '../../features/shop/screens/cart/cart.dart';
import '../../utils/constants/colors.dart';

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    
    return Stack(
      children: [
        IconButton(
          onPressed: () => Get.to(() => const CartScreen()),
          icon: const Icon(Iconsax.shopping_bag),
          color: iconColor,
        ),
        
        // Dynamic cart count badge
        Obx(() {
          final itemCount = cartController.totalItems.value;
          
          // Only show badge if there are items in cart
          if (itemCount == 0) {
            return const SizedBox.shrink();
          }
          
          return Positioned(
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.red, // Changed to red for better visibility
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : '$itemCount', // Show 99+ for large numbers
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(
                        color: TColors.white, 
                        fontSizeFactor: itemCount > 9 ? 0.7 : 0.8, // Smaller text for 2+ digits
                      ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}