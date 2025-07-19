import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/product_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: TAppBar(
        title: Text(category.name), 
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Static Banner (kept as requested)
              const TRoundedImage(
                width: double.infinity, 
                imageUrl: TImages.banner7, 
                applyImageRadius: true,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Dynamic Products Section
              Column(
                children: [
                  /// Section Heading
                  TSectionHeading(
                    title: '${category.name} Products',
                    showActionButton: false,
                    onPressed: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Dynamic Products Grid
                  FutureBuilder<List<ProductModel>>(
                    future: productController.fetchProductsByCategory(category.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(TSizes.defaultSpace),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(TSizes.defaultSpace),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Text(
                                  'Error loading products',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems / 2),
                                Text(
                                  'Please try again later',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                ElevatedButton(
                                  onPressed: () {
                                    // Trigger rebuild by calling setState indirectly
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products = snapshot.data ?? [];

                      if (products.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(TSizes.defaultSpace),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Text(
                                  'No Products Found',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems / 2),
                                Text(
                                  'No products available in ${category.name} category',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return TGridLayout(
                        itemCount: products.length,
                        itemBuilder: (_, index) => TProductCardVertical(
                          product: products[index],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
