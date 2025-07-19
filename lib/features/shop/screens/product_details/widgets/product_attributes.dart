import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/common/widgets/chips/choice_chip.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:priyorong/features/shop/models/product_model.dart';

import '../../../../../common/widgets/section_heading.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class ProductAttributeController extends GetxController {
  static ProductAttributeController get instance => Get.find();

  // Observable variables for selected attributes
  final RxMap<String, String> selectedAttributes = <String, String>{}.obs;
  final RxString selectedSize = ''.obs;
  final RxString selectedColor = ''.obs;
  final RxDouble currentPrice = 0.0.obs;

  void selectAttribute(String attributeName, String value) {
    selectedAttributes[attributeName] = value;
    
    // Update specific attributes for easy access
    if (attributeName.toLowerCase() == 'size') {
      selectedSize.value = value;
    } else if (attributeName.toLowerCase() == 'color') {
      selectedColor.value = value;
    }
    
    update();
  }

  void updatePrice(double price) {
    currentPrice.value = price;
  }

  void resetSelection() {
    selectedAttributes.clear();
    selectedSize.value = '';
    selectedColor.value = '';
    currentPrice.value = 0.0;
  }

  Map<String, String> getSelectedAttributes() {
    return Map<String, String>.from(selectedAttributes);
  }
}

class TProductAttributes extends StatelessWidget {
  const TProductAttributes({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    // Initialize controller
    Get.put(ProductAttributeController());
    final controller = ProductAttributeController.instance;
    
    // Set initial price
    controller.updatePrice(product.actualPrice);
    
    // Return empty container if no variations or attributes
    if (product.variations.isEmpty && product.attributes.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      children: [
        // Price and selection info
        GetBuilder<ProductAttributeController>(
          builder: (controller) => CircularContainer(
            padding: const EdgeInsets.all(TSizes.md),
            backgroundColor: dark ? TColors.darkerGrey : TColors.grey,
            child: Column(
              children: [
                Row(
                  children: [
                    const TSectionHeading(title: 'Product Options', showActionButton: false),
                    const Spacer(),
                    // Show selected attributes if any
                    if (controller.selectedAttributes.isNotEmpty) ...[
                      Text(
                        'Selected: ${controller.selectedAttributes.values.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Stock and availability
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Row(
                  children: [
                    const TProductTitleText(title: 'Availability: ', smallSize: true),
                    Text(
                      product.isInStock ? 'In Stock (${product.stock})' : 'Out of Stock',
                      style: TextStyle(
                        color: product.isInStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Dynamic Attributes based on product data
        ...product.attributes.entries.map((attribute) {
          final attributeName = attribute.key;
          final attributeValues = attribute.value as List<dynamic>;
          
          return GetBuilder<ProductAttributeController>(
            builder: (controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TSectionHeading(title: attributeName, showActionButton: false),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                
                // Special handling for Color attribute
                if (attributeName.toLowerCase() == 'color') ...[
                  Wrap(
                    spacing: 8,
                    children: attributeValues.map((value) {
                      final colorValue = value.toString().toLowerCase();
                      final isSelected = controller.selectedColor.value == value.toString();
                      
                      return GestureDetector(
                        onTap: () => controller.selectAttribute(attributeName, value.toString()),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 8, bottom: 8),
                          decoration: BoxDecoration(
                            color: _getColorFromString(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? TColors.primary : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected 
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  // Color names below
                  Wrap(
                    spacing: 8,
                    children: attributeValues.map((value) {
                      final isSelected = controller.selectedColor.value == value.toString();
                      return Text(
                        value.toString(),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? TColors.primary : null,
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  // Regular chips for other attributes (like Size)
                  Wrap(
                    spacing: 8,
                    children: attributeValues.map((value) {
                      final isSelected = controller.selectedAttributes[attributeName] == value.toString();
                      
                      return TChoiceChip(
                        text: value.toString(),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectAttribute(attributeName, value.toString());
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: TSizes.spaceBtwItems),
              ],
            ),
          );
        }).toList(),

        // Show variations if available
        if (product.variations.isNotEmpty) ...[
          const TSectionHeading(title: 'Available Variations', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ...product.variations.map((variation) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Variation ${variation.id}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Stock: ${variation.stock}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (variation.salePrice != null && variation.salePrice! < variation.price) ...[
                      Text(
                        '৳${variation.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '৳${variation.salePrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '৳${variation.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      ],
    );
  }

  // Helper method to convert color string to Color
  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'lime':
        return Colors.lime;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
