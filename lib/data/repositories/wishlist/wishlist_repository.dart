import 'dart:convert';
import 'package:get/get.dart';

import '../../../features/shop/models/wishlist_item_model.dart';
import '../../../utils/local_storage/storage_utility.dart';

class WishlistRepository extends GetxController {
  static WishlistRepository get instance => Get.find();

  // Variables
  final _localStorage = TLocalStorage.instance;
  static const String _wishlistKey = 'wishlist_items';

  // Get user's wishlist items from local storage
  Future<List<WishlistItemModel>> getUserWishlistItems() async {
    try {
      final wishlistData = _localStorage.readData(_wishlistKey);
      if (wishlistData != null) {
        final List<dynamic> wishlistList = jsonDecode(wishlistData);
        return wishlistList.map((item) => WishlistItemModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw 'Failed to load wishlist items: $e';
    }
  }

  // Save wishlist items to local storage
  Future<void> _saveWishlistItems(List<WishlistItemModel> items) async {
    try {
      final wishlistData = jsonEncode(items.map((item) => item.toJson()).toList());
      await _localStorage.saveData(_wishlistKey, wishlistData);
    } catch (e) {
      throw 'Failed to save wishlist items: $e';
    }
  }

  // Add item to wishlist
  Future<String> addToWishlist(WishlistItemModel wishlistItem) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      
      // Check if item already exists in wishlist
      final existingItem = wishlistItems.firstWhereOrNull(
        (item) => item.productId == wishlistItem.productId
      );

      if (existingItem != null) {
        throw 'Product is already in your wishlist';
      }

      // Add new item with unique ID
      final newItem = wishlistItem.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      wishlistItems.add(newItem);
      
      await _saveWishlistItems(wishlistItems);
      return newItem.id;
    } catch (e) {
      throw 'Failed to add item to wishlist: $e';
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      wishlistItems.removeWhere((item) => item.productId == productId);
      await _saveWishlistItems(wishlistItems);
    } catch (e) {
      throw 'Failed to remove item from wishlist: $e';
    }
  }

  // Clear user's wishlist
  Future<void> clearWishlist() async {
    try {
      await _localStorage.removeData(_wishlistKey);
    } catch (e) {
      throw 'Failed to clear wishlist: $e';
    }
  }

  // Check if product is in wishlist
  Future<bool> isProductInWishlist(String productId) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      return wishlistItems.any((item) => item.productId == productId);
    } catch (e) {
      throw 'Failed to check if product is in wishlist: $e';
    }
  }

  // Get wishlist item count
  Future<int> getWishlistItemCount() async {
    try {
      final wishlistItems = await getUserWishlistItems();
      return wishlistItems.length;
    } catch (e) {
      throw 'Failed to get wishlist count: $e';
    }
  }

  // Get wishlist items by category
  Future<List<WishlistItemModel>> getWishlistItemsByCategory(String categoryId) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      return wishlistItems.where((item) => item.categoryId == categoryId).toList();
    } catch (e) {
      throw 'Failed to get wishlist items by category: $e';
    }
  }

  // Toggle wishlist item (add if not exists, remove if exists)
  Future<bool> toggleWishlistItem(WishlistItemModel wishlistItem) async {
    try {
      final exists = await isProductInWishlist(wishlistItem.productId);
      
      if (exists) {
        await removeFromWishlist(wishlistItem.productId);
        return false; // Removed from wishlist
      } else {
        await addToWishlist(wishlistItem);
        return true; // Added to wishlist
      }
    } catch (e) {
      throw 'Failed to toggle wishlist item: $e';
    }
  }

  // Get wishlist total value
  Future<double> getWishlistTotalValue() async {
    try {
      final wishlistItems = await getUserWishlistItems();
      return wishlistItems.fold<double>(0.0, (sum, item) => sum + item.price);
    } catch (e) {
      throw 'Failed to get wishlist total value: $e';
    }
  }

  // Get wishlist items by brand
  Future<List<WishlistItemModel>> getWishlistItemsByBrand(String brandId) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      return wishlistItems.where((item) => item.brandId == brandId).toList();
    } catch (e) {
      throw 'Failed to get wishlist items by brand: $e';
    }
  }

  // Search wishlist items
  Future<List<WishlistItemModel>> searchWishlistItems(String query) async {
    try {
      final wishlistItems = await getUserWishlistItems();
      if (query.isEmpty) return wishlistItems;
      
      return wishlistItems.where((item) => 
        item.productTitle.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw 'Failed to search wishlist items: $e';
    }
  }

  // Get wishlist statistics
  Future<Map<String, dynamic>> getWishlistStatistics() async {
    try {
      final wishlistItems = await getUserWishlistItems();
      final totalItems = wishlistItems.length;
      final totalValue = await getWishlistTotalValue();
      
      // Group by category
      final Map<String, int> categoryCount = {};
      final Map<String, int> brandCount = {};
      
      for (final item in wishlistItems) {
        categoryCount[item.categoryId] = (categoryCount[item.categoryId] ?? 0) + 1;
        brandCount[item.brandId] = (brandCount[item.brandId] ?? 0) + 1;
      }
      
      final averagePrice = totalItems > 0 ? totalValue / totalItems : 0.0;
      
      return {
        'totalItems': totalItems,
        'totalValue': totalValue,
        'averagePrice': averagePrice,
        'categoryCount': categoryCount,
        'brandCount': brandCount,
      };
    } catch (e) {
      throw 'Failed to get wishlist statistics: $e';
    }
  }
} 