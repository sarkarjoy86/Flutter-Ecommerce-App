import 'dart:convert';
import 'package:get/get.dart';

import '../../../features/shop/models/cart_item_model.dart';
import '../../../utils/local_storage/storage_utility.dart';

class CartRepository extends GetxController {
  static CartRepository get instance => Get.find();

  // Variables
  final _localStorage = TLocalStorage.instance;
  static const String _cartKey = 'cart_items';

  // Get user's cart items from local storage
  Future<List<CartItemModel>> getUserCartItems() async {
    try {
      final cartData = _localStorage.readData(_cartKey);
      if (cartData != null) {
        final List<dynamic> cartList = jsonDecode(cartData);
        return cartList.map((item) => CartItemModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw 'Failed to load cart items: $e';
    }
  }

  // Save cart items to local storage
  Future<void> _saveCartItems(List<CartItemModel> items) async {
    try {
      final cartData = jsonEncode(items.map((item) => item.toJson()).toList());
      await _localStorage.saveData(_cartKey, cartData);
    } catch (e) {
      throw 'Failed to save cart items: $e';
    }
  }

  // Add item to cart
  Future<String> addToCart(CartItemModel cartItem) async {
    try {
      final cartItems = await getUserCartItems();
      
      // Check if item already exists in cart
      final existingItemIndex = cartItems.indexWhere((item) => 
        item.productId == cartItem.productId &&
        item.variationId == cartItem.variationId &&
        _attributesMatch(item.selectedAttributes, cartItem.selectedAttributes)
      );

      if (existingItemIndex != -1) {
        // Update quantity if item exists
        cartItems[existingItemIndex] = cartItems[existingItemIndex].copyWith(
          quantity: cartItems[existingItemIndex].quantity + cartItem.quantity,
        );
      } else {
        // Add new item with unique ID
        final newItem = cartItem.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        cartItems.add(newItem);
      }

      await _saveCartItems(cartItems);
      return existingItemIndex != -1 ? cartItems[existingItemIndex].id : cartItems.last.id;
    } catch (e) {
      throw 'Failed to add item to cart: $e';
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    try {
      final cartItems = await getUserCartItems();
      final itemIndex = cartItems.indexWhere((item) => item.id == cartItemId);
      
      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          cartItems.removeAt(itemIndex);
        } else {
          cartItems[itemIndex] = cartItems[itemIndex].copyWith(quantity: newQuantity);
        }
        await _saveCartItems(cartItems);
      }
    } catch (e) {
      throw 'Failed to update cart item: $e';
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final cartItems = await getUserCartItems();
      cartItems.removeWhere((item) => item.id == cartItemId);
      await _saveCartItems(cartItems);
    } catch (e) {
      throw 'Failed to remove item from cart: $e';
    }
  }

  // Clear user's cart
  Future<void> clearCart() async {
    try {
      await _localStorage.removeData(_cartKey);
    } catch (e) {
      throw 'Failed to clear cart: $e';
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getUserCartItems();
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      throw 'Failed to get cart count: $e';
    }
  }

  // Get cart total amount
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getUserCartItems();
      return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    } catch (e) {
      throw 'Failed to get cart total: $e';
    }
  }

  // Helper method to compare attributes
  bool _attributesMatch(Map<String, dynamic> attr1, Map<String, dynamic> attr2) {
    if (attr1.length != attr2.length) return false;
    
    for (final key in attr1.keys) {
      if (attr1[key] != attr2[key]) return false;
    }
    
    return true;
  }

  // Get cart items by product ID
  Future<List<CartItemModel>> getCartItemsByProductId(String productId) async {
    try {
      final cartItems = await getUserCartItems();
      return cartItems.where((item) => item.productId == productId).toList();
    } catch (e) {
      throw 'Failed to get cart items by product: $e';
    }
  }

  // Check if product is in cart
  Future<bool> isProductInCart(String productId, {String? variationId}) async {
    try {
      final cartItems = await getUserCartItems();
      return cartItems.any((item) => 
        item.productId == productId && 
        (variationId == null || item.variationId == variationId)
      );
    } catch (e) {
      throw 'Failed to check if product is in cart: $e';
    }
  }

  // Get cart statistics
  Future<Map<String, dynamic>> getCartStatistics() async {
    try {
      final cartItems = await getUserCartItems();
      final totalItems = cartItems.length;
      final totalQuantity = cartItems.fold(0, (sum, item) => sum + item.quantity);
      final totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      return {
        'totalItems': totalItems,
        'totalQuantity': totalQuantity,
        'totalAmount': totalAmount,
        'averageItemPrice': totalItems > 0 ? totalAmount / totalQuantity : 0.0,
      };
    } catch (e) {
      throw 'Failed to get cart statistics: $e';
    }
  }

  // Sync cart with Firebase when user logs in (optional)
  Future<void> syncCartWithFirebase(String userId) async {
    // This method can be implemented later if you want cross-device cart sync
    // For now, cart remains local to the device
  }

  // Import cart from Firebase (when user logs in on new device)
  Future<void> importCartFromFirebase(String userId) async {
    // This method can be implemented later if you want cross-device cart sync
    // For now, cart remains local to the device
  }
} 