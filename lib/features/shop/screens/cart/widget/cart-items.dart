import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';

import '../../../../../common/widgets/add_remove_button_in_cart.dart';
import '../../../../../common/widgets/cart_item.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../common/widgets/texts/brandTitleWithvarified_icon.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key, 
    this.showControls = true,
  });

  final bool showControls;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    
    return Obx(() => ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartController.cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
      itemBuilder: (_, index) {
        final cartItem = cartController.cartItems[index];
        
        return Container(
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            color: THelperFunctions.isDarkMode(context) 
                ? TColors.darkerGrey 
                : TColors.light,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(
              color: Colors.grey.shade300.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              // Cart Item Info
              Row(
                children: [
                  // Product Image
                  cartItem.productImage.isNotEmpty
                      ? TRoundedImage(
                          imageUrl: cartItem.productImage,
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(TSizes.sm),
                          backgroundColor: THelperFunctions.isDarkMode(context) 
                              ? TColors.darkerGrey 
                              : TColors.light,
                          isNetworkImage: cartItem.productImage.startsWith('http'),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: THelperFunctions.isDarkMode(context) 
                                ? TColors.darkerGrey 
                                : TColors.light,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                  
                  const SizedBox(width: TSizes.spaceBtwItems),
                  
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title
                        TProductTitleText(
                          title: cartItem.productTitle,
                          maxLines: 2,
                        ),
                        
                        // Attributes (if any)
                        if (cartItem.selectedAttributes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            cartItem.selectedAttributes.values.join(', '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        // Price and Quantity Info
                        Row(
                          children: [
                            Text(
                              '৳${cartItem.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(' × '),
                            Text(
                              '${cartItem.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '৳${cartItem.totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Conditionally show controls based on showControls parameter
              if (showControls) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                
                // Quantity Controls and Remove Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Row(
                      children: [
                        // Decrease Quantity
                        TCircularIcon(
                          icon: Iconsax.minus,
                          width: 32,
                          height: 32,
                          size: TSizes.md,
                          color: THelperFunctions.isDarkMode(context) 
                              ? TColors.white 
                              : TColors.black,
                          backgroundColor: THelperFunctions.isDarkMode(context) 
                              ? TColors.darkerGrey 
                              : TColors.light,
                          onPressed: () => cartController.updateQuantity(
                            cartItem.id, 
                            cartItem.quantity - 1,
                          ),
                        ),
                        
                        const SizedBox(width: TSizes.spaceBtwItems),
                        
                        // Current Quantity
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${cartItem.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: TSizes.spaceBtwItems),
                        
                        // Increase Quantity
                        TCircularIcon(
                          icon: Iconsax.add,
                          width: 32,
                          height: 32,
                          size: TSizes.md,
                          color: TColors.white,
                          backgroundColor: TColors.primary,
                          onPressed: () => cartController.updateQuantity(
                            cartItem.id, 
                            cartItem.quantity + 1,
                          ),
                        ),
                      ],
                    ),
                    
                    // Remove Item Button
                    TextButton.icon(
                      onPressed: () => _showRemoveDialog(context, cartController, cartItem.id),
                      icon: const Icon(Iconsax.trash, size: 16, color: Colors.red),
                      label: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Read-only mode for checkout - just show quantity info
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${cartItem.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    ));
  }

  void _showRemoveDialog(BuildContext context, CartController cartController, String cartItemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartController.removeFromCart(cartItemId);
              Get.back();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
