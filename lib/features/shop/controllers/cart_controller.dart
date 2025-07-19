import 'package:get/get.dart';

import '../../../data/repositories/cart/cart_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final _cartRepository = Get.put(CartRepository());

  // Observable variables
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  // Load cart items
  Future<void> loadCartItems() async {
    try {
      isLoading.value = true;
      final items = await _cartRepository.getUserCartItems();
      cartItems.assignAll(items);
      updateCartTotals();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, {
    int quantity = 1,
    String? variationId,
    Map<String, dynamic>? selectedAttributes,
  }) async {
    try {
      // Check if product is in stock
      if (product.stock <= 0) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Product is out of stock');
        return;
      }

      // Check if requested quantity is available
      if (quantity > product.stock) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Only ${product.stock} items available');
        return;
      }

      final cartItem = CartItemModel(
        id: '',
        userId: '', // No longer needed for local storage
        productId: product.id,
        productTitle: product.title,
        productImage: product.bestDisplayImage, // Use the best display image
        price: product.actualPrice,
        quantity: quantity,
        variationId: variationId,
        selectedAttributes: selectedAttributes ?? {},
      );

      await _cartRepository.addToCart(cartItem);
      await loadCartItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Item added to cart successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _cartRepository.updateCartItemQuantity(cartItemId, newQuantity);
      await loadCartItems();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartRepository.removeFromCart(cartItemId);
      await loadCartItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Item removed from cart',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      await loadCartItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Cart cleared successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Update cart totals
  void updateCartTotals() {
    double total = 0.0;
    int items = 0;

    for (final item in cartItems) {
      total += item.totalPrice;
      items += item.quantity;
    }

    totalAmount.value = total;
    totalItems.value = items;
  }

  // Get cart item count
  int getCartItemCount() {
    return totalItems.value;
  }

  // Get cart total
  double getCartTotal() {
    return totalAmount.value;
  }

  // Get subtotal (without tax and shipping)
  double getSubtotal() {
    return totalAmount.value;
  }

  // Calculate tax (3% tax)
  double getTax() {
    return totalAmount.value * 0.03;
  }

  // Calculate shipping (120৳ flat rate, free over 2000৳)
  double getShipping() {
    return totalAmount.value >= 2000 ? 0.0 : 120.0;
  }

  // Get final total with tax and shipping
  double getFinalTotal() {
    return getSubtotal() + getTax() + getShipping();
  }

  // Check if cart is empty
  bool get isCartEmpty => cartItems.isEmpty;

  // Get cart item by product ID
  CartItemModel? getCartItemByProductId(String productId) {
    return cartItems.firstWhereOrNull((item) => item.productId == productId);
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  // Get product quantity in cart
  int getProductQuantityInCart(String productId) {
    final item = getCartItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  // Increment item quantity
  Future<void> incrementQuantity(String cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      await updateQuantity(cartItemId, item.quantity + 1);
    }
  }

  // Decrement item quantity
  Future<void> decrementQuantity(String cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      if (item.quantity > 1) {
        await updateQuantity(cartItemId, item.quantity - 1);
      } else {
        await removeFromCart(cartItemId);
      }
    }
  }

  // Validate cart items (check stock availability)
  Future<bool> validateCartItems() async {
    // This would typically check against current product stock
    // For now, we'll assume all items are valid
    return true;
  }

  // Get formatted price
  String getFormattedPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Refresh cart
  Future<void> refreshCart() async {
    await loadCartItems();
  }
} 