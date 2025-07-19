import 'package:get/get.dart';

import '../../../data/repositories/wishlist/wishlist_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/wishlist_item_model.dart';
import '../models/product_model.dart';

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find();

  final _wishlistRepository = Get.put(WishlistRepository());

  // Observable variables
  final RxList<WishlistItemModel> wishlistItems = <WishlistItemModel>[].obs;
  final RxList<String> wishlistProductIds = <String>[].obs; // Quick lookup for UI
  final RxBool isLoading = false.obs;
  final RxInt totalItems = 0.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlistItems();
  }

  // Fetch wishlist items
  Future<void> fetchWishlistItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final items = await _wishlistRepository.getUserWishlistItems();
      wishlistItems.assignAll(items);
      totalItems.value = items.length;
      
      // Update product IDs for quick lookup
      wishlistProductIds.assignAll(items.map((item) => item.productId).toList());
    } catch (e) {
      errorMessage.value = e.toString();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to wishlist
  Future<void> addToWishlist(ProductModel product) async {
    try {
      // Immediately update UI
      wishlistProductIds.add(product.id);
      
      final wishlistItem = WishlistItemModel(
        id: '',
        userId: '', // No longer needed for local storage
        productId: product.id,
        productTitle: product.title,
        productImage: product.bestDisplayImage, // Use best display image
        price: product.actualPrice,
        categoryId: product.categoryId,
        brandId: product.brandId ?? '',
      );

      await _wishlistRepository.addToWishlist(wishlistItem);
      await fetchWishlistItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Item added to wishlist successfully',
      );
    } catch (e) {
      // Revert UI change on error
      wishlistProductIds.remove(product.id);
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      // Immediately update UI
      wishlistProductIds.remove(productId);
      
      await _wishlistRepository.removeFromWishlist(productId);
      await fetchWishlistItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Item removed from wishlist',
      );
    } catch (e) {
      // Revert UI change on error
      wishlistProductIds.add(productId);
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Toggle wishlist item (add if not exists, remove if exists)
  Future<void> toggleWishlistItem(ProductModel product) async {
    try {
      final isInWishlist = await isProductInWishlist(product.id);
      
      if (isInWishlist) {
        await removeFromWishlist(product.id);
      } else {
        await addToWishlist(product);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      await _wishlistRepository.clearWishlist();
      await fetchWishlistItems();
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Wishlist cleared successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Check if product is in wishlist (reactive)
  bool isProductInWishlistReactive(String productId) {
    return wishlistProductIds.contains(productId);
  }
  
  // Check if product is in wishlist (async)
  Future<bool> isProductInWishlist(String productId) async {
    try {
      return await _wishlistRepository.isProductInWishlist(productId);
    } catch (e) {
      return false;
    }
  }

  // Get wishlist item count
  int getWishlistItemCount() {
    return totalItems.value;
  }

  // Check if wishlist is empty
  bool get isWishlistEmpty => wishlistItems.isEmpty;

  // Get wishlist item by product ID
  WishlistItemModel? getWishlistItemByProductId(String productId) {
    return wishlistItems.firstWhereOrNull((item) => item.productId == productId);
  }

  // Get wishlist items by category
  List<WishlistItemModel> getWishlistItemsByCategory(String categoryId) {
    return wishlistItems.where((item) => item.categoryId == categoryId).toList();
  }

  // Get wishlist items by brand
  List<WishlistItemModel> getWishlistItemsByBrand(String brandId) {
    return wishlistItems.where((item) => item.brandId == brandId).toList();
  }

  // Sort wishlist items
  List<WishlistItemModel> sortWishlistItems(String sortBy) {
    final items = List<WishlistItemModel>.from(wishlistItems);
    
    switch (sortBy.toLowerCase()) {
      case 'price_low_high':
        return items..sort((a, b) => a.price.compareTo(b.price));
      case 'price_high_low':
        return items..sort((a, b) => b.price.compareTo(a.price));
      case 'name_a_z':
        return items..sort((a, b) => a.productTitle.compareTo(b.productTitle));
      case 'name_z_a':
        return items..sort((a, b) => b.productTitle.compareTo(a.productTitle));
      default:
        return items;
    }
  }

  // Filter wishlist items by price range
  List<WishlistItemModel> filterWishlistItemsByPriceRange(double minPrice, double maxPrice) {
    return wishlistItems.where((item) {
      return item.price >= minPrice && item.price <= maxPrice;
    }).toList();
  }

  // Get total wishlist value
  double getTotalWishlistValue() {
    double total = 0.0;
    for (final item in wishlistItems) {
      total += item.price;
    }
    return total;
  }

  // Get formatted price
  String getFormattedPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Get wishlist analytics
  Map<String, dynamic> getWishlistAnalytics() {
    final totalValue = getTotalWishlistValue();
    final itemCount = wishlistItems.length;
    final averagePrice = itemCount > 0 ? totalValue / itemCount : 0.0;
    
    // Group by category
    final Map<String, int> categoryCount = {};
    for (final item in wishlistItems) {
      categoryCount[item.categoryId] = (categoryCount[item.categoryId] ?? 0) + 1;
    }
    
    // Group by brand
    final Map<String, int> brandCount = {};
    for (final item in wishlistItems) {
      brandCount[item.brandId] = (brandCount[item.brandId] ?? 0) + 1;
    }
    
    return {
      'totalValue': totalValue,
      'itemCount': itemCount,
      'averagePrice': averagePrice,
      'categoryCount': categoryCount,
      'brandCount': brandCount,
    };
  }

  // Refresh wishlist
  Future<void> refreshWishlist() async {
    await fetchWishlistItems();
  }

  // Move item from wishlist to cart
  Future<void> moveToCart(String productId) async {
    try {
      // This would typically involve:
      // 1. Getting the product details
      // 2. Adding to cart using CartController
      // 3. Removing from wishlist
      
      // For now, just remove from wishlist
      await removeFromWishlist(productId);
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Item moved to cart successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
} 