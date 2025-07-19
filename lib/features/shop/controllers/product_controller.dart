import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


import '../../../data/repositories/products/product_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final _productRepository = Get.put(ProductRepository());

  // Observable variables
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFeatured = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    fetchFeaturedProducts();
    fetchAllProducts(); // Load all products on initialization
  }

  // Fetch all products
  Future<void> fetchAllProducts() async {
    try {
      print('🔄 ProductController: Starting to fetch all products...');
      isLoading.value = true;
      errorMessage.value = '';

      final products = await _productRepository.getAllProducts();
      print('✅ ProductController: Fetched ${products.length} products');
      
      for (int i = 0; i < products.length; i++) {
        print('📦 Product $i: ${products[i].title} (ID: ${products[i].id})');
      }
      
      allProducts.assignAll(products);
      print('🎯 ProductController: All products assigned to observable list');
    } catch (e) {
      print('❌ ProductController Error: $e');
      errorMessage.value = e.toString();
      
      // Show specific error message based on error type
      String errorTitle = 'Error';
      String errorMsg = e.toString();
      
      if (e.toString().contains('PERMISSION_DENIED') || e.toString().contains('permission-denied')) {
        errorTitle = 'Permission Denied';
        errorMsg = 'Products cannot be accessed. Please check Firebase security rules.';
      } else if (e.toString().contains('network') || e.toString().contains('UNAVAILABLE')) {
        errorTitle = 'Network Error';
        errorMsg = 'Please check your internet connection and try again.';
      }
      
      TLoaders.errorSnackBar(title: errorTitle, message: errorMsg);
    } finally {
      isLoading.value = false;
      print('🔚 ProductController: Finished fetching all products');
    }
  }

  // Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      print('🔄 ProductController: Starting to fetch featured products...');
      isLoadingFeatured.value = true;
      errorMessage.value = '';

      final products = await _productRepository.getFeaturedProducts();
      print('✅ ProductController: Fetched ${products.length} featured products');
      
      for (int i = 0; i < products.length; i++) {
        print('⭐ Featured Product $i: ${products[i].title} (Featured: ${products[i].isFeatured})');
      }
      
      featuredProducts.assignAll(products);
      print('🎯 ProductController: Featured products assigned to observable list');
    } catch (e) {
      print('❌ ProductController Featured Error: $e');
      errorMessage.value = e.toString();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingFeatured.value = false;
      print('🔚 ProductController: Finished fetching featured products');
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId, {int? limit}) async {
    try {
      return await _productRepository.getProductsByCategory(categoryId, limit: limit);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }



  // Fetch products by brand
  Future<List<ProductModel>> fetchProductsByBrand(String brandId, {int? limit}) async {
    try {
      return await _productRepository.getProductsByBrand(brandId, limit: limit);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }

  // Get single product
  Future<ProductModel?> getProduct(String productId) async {
    try {
      return await _productRepository.getProductById(productId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return null;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return [];
      return await _productRepository.searchProducts(query);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }

  // Get product stock status
  String getProductStockStatus(int stock) {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'In Stock';
  }

  // Get product availability
  bool isProductAvailable(ProductModel product) {
    return product.isActive && product.stock > 0;
  }

  // Get product variation price
  double getVariationPrice(ProductModel product, String variationId) {
    if (product.variations.isEmpty) return product.actualPrice;
    
    final variation = product.variations.firstWhereOrNull(
      (v) => v.id == variationId,
    );
    
    return variation?.salePrice ?? variation?.price ?? product.actualPrice;
  }

  // Get product variation stock
  int getVariationStock(ProductModel product, String variationId) {
    if (product.variations.isEmpty) return product.stock;
    
    final variation = product.variations.firstWhereOrNull(
      (v) => v.id == variationId,
    );
    
    return variation?.stock ?? product.stock;
  }

  // Get product variation image
  String getVariationImage(ProductModel product, String variationId) {
    if (product.variations.isEmpty) return product.thumbnail;
    
    final variation = product.variations.firstWhereOrNull(
      (v) => v.id == variationId,
    );
    
    return variation?.image.isNotEmpty == true ? variation!.image : product.thumbnail;
  }

  // Get product price text
  String getFormattedPrice(ProductModel product, [String? variationId]) {
    double price = product.actualPrice;
    
    if (variationId != null) {
      price = getVariationPrice(product, variationId);
    }
    
    return '\$${price.toStringAsFixed(2)}';
  }

  // Get product discount percentage
  String getDiscountPercentage(ProductModel product) {
    if (product.discountPercentage > 0) {
      return '-${product.discountPercentage.toStringAsFixed(0)}%';
    }
    return '';
  }

  // Filter products by price range
  List<ProductModel> filterProductsByPriceRange(
    List<ProductModel> products,
    double minPrice,
    double maxPrice,
  ) {
    return products.where((product) {
      final price = product.actualPrice;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  // Sort products
  List<ProductModel> sortProducts(List<ProductModel> products, String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'price_low_high':
        return products..sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
      case 'price_high_low':
        return products..sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
      case 'name_a_z':
        return products..sort((a, b) => a.title.compareTo(b.title));
      case 'name_z_a':
        return products..sort((a, b) => b.title.compareTo(a.title));
      case 'rating':
        return products..sort((a, b) => b.rating.compareTo(a.rating));
      default:
        return products;
    }
  }

  // Get product attributes for filtering
  Map<String, List<String>> getProductAttributes(List<ProductModel> products) {
    final Map<String, Set<String>> attributeMap = {};
    
    for (final product in products) {
      for (final attribute in product.attributes.entries) {
        final key = attribute.key;
        final values = attribute.value as List<dynamic>;
        
        if (attributeMap.containsKey(key)) {
          attributeMap[key]!.addAll(values.map((v) => v.toString()));
        } else {
          attributeMap[key] = values.map((v) => v.toString()).toSet();
        }
      }
    }
    
    return attributeMap.map((key, value) => MapEntry(key, value.toList()));
  }

  // Clear products
  void clearProducts() {
    allProducts.clear();
    featuredProducts.clear();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchAllProducts();
    await fetchFeaturedProducts();
  }


} 