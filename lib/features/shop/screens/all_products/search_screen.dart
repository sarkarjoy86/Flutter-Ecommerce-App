import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();
  
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Search Products'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
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
                  // Add a small delay to avoid too many API calls
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _performSearch(value);
                    }
                  });
                } else {
                  _performSearch('');
                }
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Search Results
          Expanded(
            child: _buildSearchContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 64,
              color: TColors.grey,
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Search for products',
              style: TextStyle(
                fontSize: 18,
                color: TColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              'Enter product name to find what you\'re looking for',
              style: TextStyle(
                color: TColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
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
            const SizedBox(height: TSizes.spaceBtwItems),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              child: const Text('Clear Search'),
            ),
          ],
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