import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/features/shop/screens/order/widgets/order_list.dart';
import 'package:priyorong/features/shop/controllers/order_controller.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get OrderController and load orders if needed
    final orderController = Get.find<OrderController>();
    
    // Load orders when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadUserOrders();
    });
    
    return Scaffold(
      // AppBar
      appBar: TAppBar(
        title: Text('My Orders', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
        actions: [
          IconButton(
            onPressed: () => orderController.loadUserOrders(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() {
          if (orderController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (orderController.orders.isEmpty) {
            return _buildEmptyOrdersView(context);
          }
          
          return const TOrderListItems();
        }),
      ), // Padding
    ); // Scaffold
  }

  Widget _buildEmptyOrdersView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'No Orders Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Text(
            'Start shopping to see your orders here!',
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
}

