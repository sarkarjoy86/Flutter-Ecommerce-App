import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/product_cards/product_card_vertical.dart';
import 'package:priyorong/features/shop/controllers/product_controller.dart';

import '../../utils/constants/sizes.dart';
import 'layouts/grid_layout.dart';
import 'package:priyorong/features/shop/models/product_model.dart';

class TSortableProducts extends StatefulWidget {
  const TSortableProducts({
    super.key,
  });

  @override
  State<TSortableProducts> createState() => _TSortableProductsState();
}

class _TSortableProductsState extends State<TSortableProducts> {
  String _selectedSort = 'Name';

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    
    return Column(
      children: [
        // Dropdown for sorting
        DropdownButtonFormField<String>(
          value: _selectedSort,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.sort),
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSort = value;
              });
            }
          },
          items: ['Name', 'Higher Price', 'Lower Price', 'Sale', 'Popularity']
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        // Products List from Firebase
        Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = List<ProductModel>.from(productController.allProducts);
          if (products.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }
          // Apply sorting
          List<ProductModel> sortedProducts = List<ProductModel>.from(products);
          switch (_selectedSort) {
            case 'Name':
              sortedProducts.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              break;
            case 'Higher Price':
              sortedProducts.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
              break;
            case 'Lower Price':
              sortedProducts.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
              break;
            case 'Sale':
              sortedProducts.sort((a, b) {
                final aSale = a.isOnSale ? 1 : 0;
                final bSale = b.isOnSale ? 1 : 0;
                return bSale.compareTo(aSale);
              });
              break;
            case 'Popularity':
              sortedProducts.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
              break;
          }
          return TGridLayout(
            itemCount: sortedProducts.length,
            itemBuilder: (_, index) => TProductCardVertical(
              product: sortedProducts[index],
            ),
          );
        }),
      ],
    );
  }
}