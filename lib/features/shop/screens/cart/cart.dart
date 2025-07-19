import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';
import 'package:priyorong/features/shop/screens/cart/widget/cart-items.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../checkout/checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          // Cart item count badge
          Obx(() => cartController.totalItems.value > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cartController.totalItems.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (cartController.isCartEmpty) {
          return _buildEmptyCart(context);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
                             // Cart Items (with controls)
               const TCartItems(showControls: true),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Cart Summary
              _buildCartSummary(context, cartController),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => cartController.isCartEmpty
          ? const SizedBox()
          : _buildBottomCheckout(context, cartController)),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.shopping_cart,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Your Cart is Empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Text(
            'Add some products to get started!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('    Continue Shopping    '),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartController cartController) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          
          // Subtotal
          _buildSummaryRow(
            context, 
            'Subtotal', 
            '৳${cartController.getSubtotal().toStringAsFixed(2)}',
          ),
          
          // Tax
          _buildSummaryRow(
            context, 
            'Tax (3%)', 
            '৳${cartController.getTax().toStringAsFixed(2)}',
          ),
          
          // Shipping
          _buildSummaryRow(
            context, 
            'Shipping', 
            cartController.getShipping() == 0 
                ? 'Free' 
                : '৳${cartController.getShipping().toStringAsFixed(0)}',
            subtitle: cartController.getShipping() == 0 
                ? 'Free shipping on orders over ৳2000' 
                : null,
          ),
          
          const Divider(height: TSizes.spaceBtwItems * 2),
          
          // Total
          _buildSummaryRow(
            context, 
            'Total', 
            '৳${cartController.getFinalTotal().toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, 
    String label, 
    String value, {
    String? subtitle,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: isTotal 
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                value,
                style: isTotal 
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(BuildContext context, CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cartController.totalItems.value} items',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Total: ৳${cartController.getFinalTotal().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),
              
              // Checkout button
              ElevatedButton(
                onPressed: () => Get.to(() => const CheckoutScreen()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.spaceBtwItems * 2,
                    vertical: TSizes.spaceBtwItems,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Checkout'),
                    const SizedBox(width: 8),
                    const Icon(Iconsax.arrow_right_3, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
