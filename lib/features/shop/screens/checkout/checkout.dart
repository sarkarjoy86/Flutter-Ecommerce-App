import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:priyorong/common/widgets/success_screen.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';
import 'package:priyorong/features/shop/controllers/order_controller.dart';
import 'package:priyorong/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:priyorong/features/shop/screens/checkout/widgets/billing_payment_section.dart';
import 'package:priyorong/navigation_menu.dart';
import 'package:priyorong/utils/constants/image_strings.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/coupon_widget.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../cart/widget/cart-items.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:priyorong/features/shop/models/cart_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatelessWidget {
  final ProductModel? directProduct;
  final int? directQuantity;
  final String? selectedSize;
  const CheckoutScreen({Key? key, this.directProduct, this.directQuantity, this.selectedSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final isDirect = directProduct != null && directQuantity != null;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final tempCartItems = isDirect
        ? [
            CartItemModel(
              id: '',
              userId: userId,
              productId: directProduct!.id,
              productTitle: directProduct!.title,
              productImage: directProduct!.thumbnail,
              price: directProduct!.actualPrice,
              quantity: directQuantity!,
              selectedAttributes: {
                if (selectedSize != null) 'Size': selectedSize!,
              },
            )
          ]
        : cartController.cartItems;
    double subtotal = tempCartItems.fold(0, (sum, item) => sum + item.totalPrice);
    double tax = subtotal * 0.03;
    double shipping = subtotal > 2000 ? 0 : 120;
    double total = subtotal + tax + shipping;
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Order Review',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Product(s) Summary
              ...tempCartItems.map((item) {
                String imageUrl = '';
                if (item.productImage.isNotEmpty && (item.productImage.startsWith('http://') || item.productImage.startsWith('https://'))) {
                  imageUrl = item.productImage;
                } else if (directProduct != null && directProduct?.images != null && (directProduct?.images as List).isNotEmpty) {
                  final firstImage = (directProduct?.images as List).first;
                  if (firstImage is String && (firstImage.startsWith('http://') || firstImage.startsWith('https://'))) {
                    imageUrl = firstImage;
                  }
                }
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, width: 90, height: 90, fit: BoxFit.cover)
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.productTitle, style: Theme.of(context).textTheme.titleMedium),
                              Text('৳${item.price.toStringAsFixed(2)} × ${item.quantity}'),
                              if (item.selectedAttributes.isNotEmpty)
                                Text(item.selectedAttributes.entries.map((e) => '${e.key}: ${e.value}').join(', ')),
                            ],
                          ),
                        ),
                        Text('৳${item.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: TSizes.spaceBtwSections),
              // Promo code
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Have a promo code? Enter here',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: const Text('Apply')),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              // Order Summary
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Subtotal', '৳${subtotal.toStringAsFixed(2)}'),
                      _buildSummaryRow('Tax (3%)', '৳${tax.toStringAsFixed(2)}'),
                      _buildSummaryRow('Shipping Fee', shipping == 0 ? 'Free' : '৳${shipping.toStringAsFixed(0)}'),
                      const Divider(),
                      _buildSummaryRow('Order Total', '৳${total.toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              // Payment Methods
              const TBillingPaymentSection(),
              const SizedBox(height: TSizes.spaceBtwItems),
              // Address
              const TBillingAddressSection(),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: orderController.isCreatingOrder.value
              ? null
              : () async {
                  if (isDirect) {
                    await orderController.createOrderForProduct(
                      directProduct!,
                      directQuantity!,
                      selectedSize: selectedSize,
                    );
                  } else {
                    await orderController.createOrderFromCart();
                  }
                  if (!orderController.isCreatingOrder.value) {
                    Get.to(() => SuccessScreen(
                          image: TImages.successfulPaymentIcon,
                          title: 'Order Placed Successfully!',
                          subtitle: 'Your order has been placed and will be shipped soon',
                          onPressed: () => Get.offAll(() => const NavigationMenu()),
                        ));
                  }
                },
          child: orderController.isCreatingOrder.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text('Checkout ৳${total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.red) : null),
        ],
      ),
    );
  }
}
