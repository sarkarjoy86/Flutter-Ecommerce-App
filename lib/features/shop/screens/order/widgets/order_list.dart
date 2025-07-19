import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:priyorong/features/shop/controllers/order_controller.dart';
import 'package:priyorong/features/shop/models/order_model.dart';
import 'package:priyorong/features/shop/screens/order/order_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../../data/repositories/products/product_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../product_reviews/write_review_screen.dart';

class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    // Get lazy-loaded OrderController
    final orderController = Get.find<OrderController>();
    
    return Obx(() => ListView.separated(
      shrinkWrap: true,
      itemCount: orderController.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, index) {
        final order = orderController.orders[index];
        final statusColor = orderController.getOrderStatusColor(order.status);
        final statusIcon = orderController.getOrderStatusIcon(order.status);
        final statusText = orderController.getOrderStatusText(order.status);
        
        return GestureDetector(
          onTap: () => Get.to(() => OrderDetailsScreen(order: order)),
          child: CircularContainer(
            showBorder: true,
            padding: const EdgeInsets.all(TSizes.md),
            backgroundColor: dark ? TColors.dark : TColors.light,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1 - Status and Date
                Row(
                  children: [
                    // Status Icon
                    Icon(statusIcon, color: statusColor),
                    const SizedBox(width: TSizes.spaceBtwItems / 2),

                    // Status & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: statusColor,
                              fontWeightDelta: 1,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(order.orderDate),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    
                    // Actions Menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'cancel' && order.status == OrderStatus.pending) {
                          orderController.cancelOrder(order.id);
                        } else if (value == 'details') {
                          Get.to(() => OrderDetailsScreen(order: order));
                        }
                      },
                      itemBuilder: (context) => [
                        if (order.status == OrderStatus.pending)
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, size: 16),
                                SizedBox(width: 8),
                                Text('Cancel Order'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        size: TSizes.iconSm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Row 2 - Order Details
                Row(
                  children: [
                    // Order Number
                    Row(
                      children: [
                        const Icon(Iconsax.tag),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Number',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              order.orderNumber,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: TSizes.spaceBtwItems),
                
                // Row 3 - Order Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.fold(0, (sum, item) => sum + item.quantity)} item${order.items.fold(0, (sum, item) => sum + item.quantity) > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '৳${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Write Review Buttons for Delivered Orders
                if (order.status == OrderStatus.delivered) ...[
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.items.map((item) => FutureBuilder<bool>(
                      future: _hasUserReviewed(item.productId),
                      builder: (context, snapshot) {
                        final hasReviewed = snapshot.data ?? false;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: TextButton.icon(
                            icon: Icon(
                              hasReviewed ? Icons.edit : Icons.rate_review,
                              color: TColors.primary,
                              size: 18,
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              foregroundColor: TColors.primary,
                              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            label: Text(hasReviewed ? 'Update Review' : 'Write Review'),
                            onPressed: () async {
                              final productRepo = Get.find<ProductRepository>();
                              try {
                                final product = await productRepo.getProductById(item.productId);
                                Get.to(() => WriteReviewScreen(
                                  product: product,
                                  isEditing: hasReviewed,
                                ));
                              } catch (e) {
                                Get.snackbar('Error', 'Could not load product info for review.');
                              }
                            },
                          ),
                        );
                      },
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ));
  }
}

Future<bool> _hasUserReviewed(String productId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection('Reviews')
      .where('ProductId', isEqualTo: productId)
      .where('UserId', isEqualTo: user.uid)
      .limit(1)
      .get();
  return snapshot.docs.isNotEmpty;
}
