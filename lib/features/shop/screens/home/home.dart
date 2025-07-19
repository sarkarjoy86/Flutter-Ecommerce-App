import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/home_Categories.dart';
import 'package:priyorong/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:priyorong/features/shop/controllers/product_controller.dart';
import 'package:priyorong/utils/constants/sizes.dart';

import '../../../../common/widgets/home_appbar.dart';
import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/primary_header_container.dart';
import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../all_products/all_products.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  const THomeAppbar(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Functional Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for Products',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                                onPressed: _clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                          borderSide: const BorderSide(color: TColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                          borderSide: const BorderSide(color: TColors.primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                          borderSide: const BorderSide(color: TColors.grey),
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
                          _clearSearch();
                        }
                      },
                      onSubmitted: _performSearch,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Categories (only show when not searching)
                  if (!_showSearchResults) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: TSizes.defaultSpace),
                      child: Column(
                        children: [
                          TSectionHeading(
                            title: 'Popular Categories',
                            showActionButton: false,
                            textColor: Colors.white,
                          ),
                          SizedBox(height: TSizes.spaceBtwItems),

                          /// Categories List
                          ThomeCategories(),
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections * 1.5),
                  ],
                ],
              ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Show search results when searching
                  if (_showSearchResults) ...[
                    _buildSearchResults(),
                  ] else ...[
                    /// Regular home content when not searching
                    const THomeSlider(),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Heading
                    TSectionHeading(
                        title: 'Popular Products',
                        onPressed: () => Get.to(() => const ALLProducts())),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Featured Products from Firebase
                    GetBuilder<ProductController>(
                      builder: (productController) {
                        if (productController.isLoadingFeatured.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final featuredProducts = productController.featuredProducts;

                        if (featuredProducts.isEmpty) {
                          return const Center(
                            child: Text('No featured products available'),
                          );
                        }

                        return TGridLayout(
                          itemCount: featuredProducts.length > 4 ? 4 : featuredProducts.length,
                          itemBuilder: (_, index) => TProductCardVertical(
                            product: featuredProducts[index],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),
                    const TRoundedImage(
                        width: double.infinity,
                        imageUrl: TImages.banner2,
                        applyImageRadius: true),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// More Featured Products
                    GetBuilder<ProductController>(
                      builder: (productController) {
                        final featuredProducts = productController.featuredProducts;

                        if (featuredProducts.length <= 4) {
                          return const SizedBox(); // Don't show if we have 4 or fewer products
                        }

                        return TGridLayout(
                          itemCount: featuredProducts.length > 6 ? 2 : featuredProducts.length - 4,
                          itemBuilder: (_, index) => TProductCardVertical(
                            product: featuredProducts[index + 4], // Start from 5th product
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
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

    return Column(
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
    );
  }
}




