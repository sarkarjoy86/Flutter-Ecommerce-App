import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/orders/order_repository.dart';
import '../../../data/repositories/addresses/address_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../../personalization/controllers/user_controller.dart';
import 'cart_controller.dart';
import '../models/product_model.dart';
import '../../../data/repositories/products/product_repository.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  // Dependencies
  final _orderRepository = Get.put(OrderRepository());
  final _addressRepository = Get.put(AddressRepository());
  final _cartController = Get.find<CartController>();
  final _userController = Get.find<UserController>();
  final _productRepository = Get.put(ProductRepository());

  // Observable variables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreatingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load orders automatically to prevent initialization issues
    // Orders will be loaded when the order screen is accessed
  }

  // Generate unique order number in AJS-PR-XXXXXX format
  String _generateOrderNumber() {
    final random = Random();
    final randomNumber = random.nextInt(900000) + 100000; // 6-digit random number
    return 'PR-AJS-$randomNumber';
  }



  // Create new order from cart
  Future<void> createOrderFromCart() async {
    try {
      isCreatingOrder.value = true;

      // Check if cart is empty
      if (_cartController.isCartEmpty) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Cart is empty');
        return;
      }

      // Check if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Please login to place order');
        return;
      }

      // Check if address is selected
      final selectedAddress = await _addressRepository.getSelectedAddress();
      if (selectedAddress == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Please select delivery address');
        return;
      }

      // Convert cart items to order items (only extract size from attributes)
      final orderItems = _cartController.cartItems.map((cartItem) => 
        OrderItemModel(
          productId: cartItem.productId,
          productTitle: cartItem.productTitle,
          price: cartItem.price,
          quantity: cartItem.quantity,
          size: cartItem.selectedAttributes['Size'] as String?, // Only extract size
        )).toList();

      // Create order model
      final order = OrderModel(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        customerName: _userController.user.value.fullName,
        orderNumber: _generateOrderNumber(),
        items: orderItems,
        totalAmount: _cartController.getFinalTotal(),
        status: OrderStatus.pending,
        shippingAddress: ShippingAddress(
          fullName: selectedAddress.name,
          phone: selectedAddress.phoneNumber,
          street: selectedAddress.street,
          city: selectedAddress.city,
          state: selectedAddress.state,
          zipCode: selectedAddress.postcode,
          country: selectedAddress.country,
        ),
        orderDate: DateTime.now(),
      );

      // Save order to Firebase
      final orderId = await _orderRepository.createOrder(order);
      
      if (orderId.isNotEmpty) {
        // Reduce stock for each product
        for (final item in order.items) {
          await _productRepository.reduceProductStock(item.productId, item.quantity);
        }
        // Clear cart after successful order creation
        await _cartController.clearCart();
        
        // Refresh orders list
        await loadUserOrders();
        
        TLoaders.successSnackBar(
          title: 'Order Placed!', 
          message: 'Your order ${order.orderNumber} has been placed successfully'
        );
      }

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isCreatingOrder.value = false;
    }
  }

  // Create new order for a single product (direct checkout)
  Future<void> createOrderForProduct(ProductModel product, int quantity, {String? selectedSize}) async {
    try {
      isCreatingOrder.value = true;
      // Check if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Please login to place order');
        return;
      }
      // Check if address is selected
      final selectedAddress = await _addressRepository.getSelectedAddress();
      if (selectedAddress == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Please select delivery address');
        return;
      }
      // Create order item
      final orderItem = OrderItemModel(
        productId: product.id,
        productTitle: product.title,
        price: product.actualPrice,
        quantity: quantity,
        size: selectedSize,
      );
      // Create order model
      final order = OrderModel(
        id: '',
        userId: currentUser.uid,
        customerName: _userController.user.value.fullName,
        orderNumber: _generateOrderNumber(),
        items: [orderItem],
        totalAmount: product.actualPrice * quantity,
        status: OrderStatus.pending,
        shippingAddress: ShippingAddress(
          fullName: selectedAddress.name,
          phone: selectedAddress.phoneNumber,
          street: selectedAddress.street,
          city: selectedAddress.city,
          state: selectedAddress.state,
          zipCode: selectedAddress.postcode,
          country: selectedAddress.country,
        ),
        orderDate: DateTime.now(),
      );
      // Save order to Firebase
      final orderId = await _orderRepository.createOrder(order);
      if (orderId.isNotEmpty) {
        // Reduce stock for the product
        await _productRepository.reduceProductStock(product.id, quantity);
        await loadUserOrders();
        TLoaders.successSnackBar(
          title: 'Order Placed!',
          message: 'Your order ${order.orderNumber} has been placed successfully',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isCreatingOrder.value = false;
    }
  }

  // Load user's orders
  Future<void> loadUserOrders() async {
    try {
      isLoading.value = true;
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userOrders = await _orderRepository.getUserOrders(currentUser.uid);
        // Sort orders by orderDate descending (most recent first)
        userOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        orders.assignAll(userOrders);
      }
      
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _orderRepository.getOrderById(orderId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return null;
    }
  }

  // Update order status (for admin panel later)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      await loadUserOrders(); // Refresh orders
      
      TLoaders.successSnackBar(
        title: 'Status Updated', 
        message: 'Order status updated to ${status.name}'
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Cancel order (only if status is pending)
  Future<void> cancelOrder(String orderId) async {
    try {
      final order = orders.firstWhereOrNull((o) => o.id == orderId);
      
      if (order == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Order not found');
        return;
      }

      if (order.status != OrderStatus.pending) {
        TLoaders.errorSnackBar(
          title: 'Cannot Cancel', 
          message: 'Order cannot be cancelled at this stage'
        );
        return;
      }

      await updateOrderStatus(orderId, OrderStatus.cancelled);
      
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  // Get order status color
  Color getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case OrderStatus.processing:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.shipped:
        return const Color(0xFF9C27B0); // Purple
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // Get order status icon
  IconData getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Get readable status text
  String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
} 