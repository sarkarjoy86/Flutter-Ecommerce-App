import 'package:get/get.dart';

import '../../../data/repositories/brands/brand_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/brand_model.dart';

class BrandController extends GetxController {
  static BrandController get instance => Get.find();

  final _brandRepository = Get.put(BrandRepository());

  // Observable variables
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxList<BrandModel> featuredBrands = <BrandModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFeatured = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedBrands();
  }

  // Fetch all brands
  Future<void> fetchAllBrands() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final brands = await _brandRepository.getAllBrands();
      allBrands.assignAll(brands);
    } catch (e) {
      errorMessage.value = e.toString();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch featured brands
  Future<void> fetchFeaturedBrands() async {
    try {
      isLoadingFeatured.value = true;
      errorMessage.value = '';

      final brands = await _brandRepository.getFeaturedBrands();
      featuredBrands.assignAll(brands);
    } catch (e) {
      errorMessage.value = e.toString();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  // Get single brand
  Future<BrandModel?> getBrand(String brandId) async {
    try {
      return await _brandRepository.getBrandById(brandId);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
      return null;
    }
  }

  // Get brand by name
  BrandModel? getBrandByName(String brandName) {
    return allBrands.firstWhereOrNull(
      (brand) => brand.name.toLowerCase() == brandName.toLowerCase(),
    );
  }

  // Search brands
  List<BrandModel> searchBrands(String query) {
    if (query.isEmpty) return allBrands;
    
    return allBrands.where((brand) {
      return brand.name.toLowerCase().contains(query.toLowerCase()) ||
             brand.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Sort brands
  List<BrandModel> sortBrands(List<BrandModel> brands, String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'name_a_z':
        return brands..sort((a, b) => a.name.compareTo(b.name));
      case 'name_z_a':
        return brands..sort((a, b) => b.name.compareTo(a.name));
      case 'product_count_high_low':
        return brands..sort((a, b) => b.productCount.compareTo(a.productCount));
      case 'product_count_low_high':
        return brands..sort((a, b) => a.productCount.compareTo(b.productCount));
      default:
        return brands;
    }
  }

  // Filter brands
  List<BrandModel> filterBrands(List<BrandModel> brands, {
    bool? isFeatured,
    bool? isActive,
    int? minProductCount,
    int? maxProductCount,
  }) {
    return brands.where((brand) {
      bool matchesFeatured = isFeatured == null || brand.isFeatured == isFeatured;
      bool matchesActive = isActive == null || brand.isActive == isActive;
      bool matchesMinProducts = minProductCount == null || brand.productCount >= minProductCount;
      bool matchesMaxProducts = maxProductCount == null || brand.productCount <= maxProductCount;
      
      return matchesFeatured && matchesActive && matchesMinProducts && matchesMaxProducts;
    }).toList();
  }

  // Get brand statistics
  Map<String, dynamic> getBrandStatistics() {
    final totalBrands = allBrands.length;
    final featuredBrandsCount = allBrands.where((brand) => brand.isFeatured).length;
    final activeBrandsCount = allBrands.where((brand) => brand.isActive).length;
    final inactiveBrandsCount = totalBrands - activeBrandsCount;
    
    int totalProducts = 0;
    for (final brand in allBrands) {
      totalProducts += brand.productCount;
    }
    
    final averageProductsPerBrand = totalBrands > 0 ? totalProducts / totalBrands : 0.0;
    
    return {
      'totalBrands': totalBrands,
      'featuredBrands': featuredBrandsCount,
      'activeBrands': activeBrandsCount,
      'inactiveBrands': inactiveBrandsCount,
      'totalProducts': totalProducts,
      'averageProductsPerBrand': averageProductsPerBrand,
    };
  }

  // Get top brands by product count
  List<BrandModel> getTopBrands({int limit = 10}) {
    final sortedBrands = List<BrandModel>.from(allBrands)
      ..sort((a, b) => b.productCount.compareTo(a.productCount));
    
    return sortedBrands.take(limit).toList();
  }

  // Get active brands
  List<BrandModel> getActiveBrands() {
    return allBrands.where((brand) => brand.isActive).toList();
  }

  // Get inactive brands
  List<BrandModel> getInactiveBrands() {
    return allBrands.where((brand) => !brand.isActive).toList();
  }

  // Get brands with products
  List<BrandModel> getBrandsWithProducts() {
    return allBrands.where((brand) => brand.productCount > 0).toList();
  }

  // Get brands without products
  List<BrandModel> getBrandsWithoutProducts() {
    return allBrands.where((brand) => brand.productCount == 0).toList();
  }

  // Check if brand exists
  bool brandExists(String brandName) {
    return allBrands.any((brand) => 
      brand.name.toLowerCase() == brandName.toLowerCase()
    );
  }

  // Get brand image or logo
  String getBrandImage(BrandModel brand, {bool useLogo = false}) {
    if (useLogo && brand.logo.isNotEmpty) {
      return brand.logo;
    }
    return brand.image.isNotEmpty ? brand.image : brand.logo;
  }

  // Group brands by first letter
  Map<String, List<BrandModel>> groupBrandsByLetter() {
    final Map<String, List<BrandModel>> groupedBrands = {};
    
    for (final brand in allBrands) {
      final firstLetter = brand.name.isNotEmpty ? brand.name[0].toUpperCase() : '#';
      
      if (groupedBrands.containsKey(firstLetter)) {
        groupedBrands[firstLetter]!.add(brand);
      } else {
        groupedBrands[firstLetter] = [brand];
      }
    }
    
    // Sort each group alphabetically
    groupedBrands.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });
    
    return groupedBrands;
  }

  // Clear brands
  void clearBrands() {
    allBrands.clear();
    featuredBrands.clear();
  }

  // Refresh brands
  Future<void> refreshBrands() async {
    await fetchAllBrands();
    await fetchFeaturedBrands();
  }

  // Get brand display name
  String getBrandDisplayName(BrandModel brand) {
    return brand.name.isNotEmpty ? brand.name : 'Unknown Brand';
  }

  // Get brand short description
  String getBrandShortDescription(BrandModel brand, {int maxLength = 100}) {
    if (brand.description.length <= maxLength) {
      return brand.description;
    }
    return '${brand.description.substring(0, maxLength)}...';
  }

  // Check if brand is featured
  bool isBrandFeatured(String brandId) {
    return featuredBrands.any((brand) => brand.id == brandId);
  }

  // Get random featured brands
  List<BrandModel> getRandomFeaturedBrands({int count = 3}) {
    final shuffled = List<BrandModel>.from(featuredBrands)..shuffle();
    return shuffled.take(count).toList();
  }
} 