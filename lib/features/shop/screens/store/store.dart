import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/appbar/appbar.dart';
import 'package:priyorong/common/widgets/appbar/tabbar.dart';
import 'package:priyorong/common/widgets/cart_menu_icon.dart';
import 'package:priyorong/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/catagory_tab.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();
  
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _productController.searchProducts(query.trim());
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryController.instance.featuredCategories;
    
    if (_showSearchResults) {
      // Show search results view
      return Scaffold(
        appBar: TAppBar(
          title: Text(
            'Search Results',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCartCounterIcon(onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in Categories',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: _clearSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    borderSide: const BorderSide(color: TColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    borderSide: const BorderSide(color: TColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TSizes.md,
                    vertical: TSizes.sm,
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _performSearch(value);
                      }
                    });
                  } else {
                    _clearSearch();
                  }
                },
                onSubmitted: _performSearch,
              ),
            ),
            
            // Search Results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      );
    }

    // Show normal categories view
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCartCounterIcon(onPressed: () {}),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: THelperFunctions.isDarkMode(context)
                    ? TColors.black
                    : TColors.white,
                expandedHeight: 250,
                flexibleSpace: Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        /// Functional Search Bar
                        const SizedBox(height: TSizes.spaceBtwItems),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search in Categories',
                            prefixIcon: const Icon(Iconsax.search_normal),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Iconsax.close_circle),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                              borderSide: const BorderSide(color: TColors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                              borderSide: const BorderSide(color: TColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: TSizes.md,
                              vertical: TSizes.sm,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {}); // Update UI for suffix icon
                            if (value.isNotEmpty) {
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (_searchController.text == value) {
                                  _performSearch(value);
                                }
                              });
                            } else {
                              _clearSearch();
                            }
                          },
                          onSubmitted: _performSearch,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                      ],
                    )),

                /// Tabs
                bottom: TTabBar(
                    tabs: categories
                        .map((category) => Tab(child: Text(category.name)))
                        .toList()),
              ),
            ];
          },
          body: TabBarView(
              children: categories.map((category) => TCategoryTab(category: category)).toList()
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.search_status,
                size: 64,
                color: TColors.grey,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  color: TColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                'Try searching with different keywords for "${_searchController.text}"',
                style: const TextStyle(
                  color: TColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Results Header
            Text(
              'Found ${_searchResults.length} product${_searchResults.length == 1 ? '' : 's'} for "${_searchController.text}"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Products Grid
            TGridLayout(
              itemCount: _searchResults.length,
              itemBuilder: (_, index) => TProductCardVertical(
                product: _searchResults[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
