import 'package:get/get.dart';

import '../../../data/repositories/authentications/category_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final _categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  // Load category data
  Future<void> fetchCategories() async {
    try {
      // Show loader while loading categories
      isLoading.value = true;

      // Fetch categories from data source (Firestore, API, etc.)
      final categories = await _categoryRepository.getAllCategories();
      
      // Update the categories list
      allCategories.assignAll(categories);
      
      // Filter featured categories: isFeatured = true AND (parentId is empty or null)
      final featured = allCategories.where((category) => 
        category.isFeatured && 
        (category.parentId.isEmpty || category.parentId == 'null')
      ).toList();
      
      // Assign featured categories
      featuredCategories.assignAll(featured);
      
      // If no featured categories found, show all categories as fallback
      if (featuredCategories.isEmpty && allCategories.isNotEmpty) {
        featuredCategories.assignAll(allCategories);
      }
      
    } catch (e) {
      print('CategoryController Error: $e');
      
      // Show specific error message based on error type
      String errorMessage = 'Failed to load categories. Please try again.';
      String errorTitle = 'Error';
      
      if (e.toString().contains('PERMISSION_DENIED') || e.toString().contains('permission-denied')) {
        errorTitle = 'Permission Denied';
        errorMessage = 'Categories cannot be accessed. Please check Firebase security rules.';
      } else if (e.toString().contains('network') || e.toString().contains('UNAVAILABLE')) {
        errorTitle = 'Network Error';
        errorMessage = 'Please check your internet connection and try again.';
      } else if (e.toString().contains('NOT_FOUND') || e.toString().contains('not-found')) {
        errorTitle = 'Collection Not Found';
        errorMessage = 'Categories collection not found in Firebase.';
      }
      
      TLoaders.errorSnackBar(title: errorTitle, message: errorMessage);
    } finally {
      // Remove Loader
      isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

// Load selected category data
// Get Category or Sub-Category Products.
}
