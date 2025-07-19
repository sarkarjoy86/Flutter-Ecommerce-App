import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/common/widgets/layouts/grid_layout.dart';
import 'package:priyorong/common/widgets/product_cards/product_card_vertical.dart';
import 'package:priyorong/common/widgets/section_heading.dart';
import 'package:priyorong/features/shop/models/category_model.dart';
import 'package:priyorong/features/shop/controllers/product_controller.dart';

import '../../utils/constants/sizes.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Products
              TSectionHeading(
                title: '${category.name} Products', 
                onPressed: () {}
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // Load products for this category from Firebase
              FutureBuilder(
                future: productController.fetchProductsByCategory(category.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  
                  final products = snapshot.data ?? [];
                  
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No products found in this category'),
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
        ),
      ],
    );
  }
}
