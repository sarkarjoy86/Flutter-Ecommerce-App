import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:priyorong/features/shop/controllers/order_controller.dart';
import 'package:priyorong/features/shop/models/order_model.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  
  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final orderController = Get.find<OrderController>();
    
    return Scaffold(
      appBar: TAppBar(
        title: Text('Order Details', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        actions: [
          if (order.status == OrderStatus.pending)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _showCancelOrderDialog(context, orderController);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel Order', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildOrderStatusCard(context, dark),
            const SizedBox(height: TSizes.spaceBtwSections),
            
            // Order Items
            _buildOrderItemsSection(context, dark),
            const SizedBox(height: TSizes.spaceBtwSections),
            
            // Shipping Address
            _buildShippingAddressSection(context, dark),
            const SizedBox(height: TSizes.spaceBtwSections),
            
            // Order Summary
            _buildOrderSummarySection(context, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context, bool dark) {
    final statusColor = Get.find<OrderController>().getOrderStatusColor(order.status);
    final statusIcon = Get.find<OrderController>().getOrderStatusIcon(order.status);
    final statusText = Get.find<OrderController>().getOrderStatusText(order.status);
    
    return CircularContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Order ${order.orderNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                'Order Date',
                DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate),
                Iconsax.calendar,
              ),
              if (order.trackingNumber != null)
                _buildInfoItem(
                  context,
                  'Tracking',
                  order.trackingNumber!,
                  Iconsax.truck,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsSection(BuildContext context, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        ...order.items.map((item) => _buildOrderItem(context, item, dark)),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItemModel item, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: dark ? TColors.darkerGrey : Colors.white,
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.size != null) ...[
                  Text(
                    'Size: ${item.size}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Text(
                      '৳${item.price.toStringAsFixed(2)} each',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price
          Text(
            '৳${item.totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection(BuildContext context, bool dark) {
    return CircularContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.location),
              const SizedBox(width: TSizes.spaceBtwItems / 2),
              Text(
                'Shipping Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            order.shippingAddress.fullName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.shippingAddress.phone,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${order.shippingAddress.street}, ${order.shippingAddress.city}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${order.shippingAddress.state} ${order.shippingAddress.zipCode}, ${order.shippingAddress.country}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(BuildContext context, bool dark) {
    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.quantity);
    
    return CircularContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '$totalQuantity item${totalQuantity > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '৳${order.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context, OrderController orderController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              orderController.cancelOrder(order.id);
              Get.back(); // Go back to orders list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
} 