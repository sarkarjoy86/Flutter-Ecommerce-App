import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:priyorong/features/shop/controllers/cart_controller.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/product_attributes.dart';

import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/popups/loaders.dart';

class TBottomAddToCart extends StatefulWidget {
  const TBottomAddToCart({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<TBottomAddToCart> createState() => _TBottomAddToCartState();
}

class _TBottomAddToCartState extends State<TBottomAddToCart> {
  int quantity = 1;
  bool isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Quantity Controls
          Row(
            children: [
              TCircularIcon(
                icon: Iconsax.minus,
                backgroundColor: TColors.secondary,
                width: 40,
                height: 40,
                color: TColors.white,
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$quantity', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              TCircularIcon(
                icon: Iconsax.add,
                backgroundColor: TColors.primary,
                width: 40,
                height: 40,
                color: TColors.white,
                onPressed: () {
                  if (quantity < widget.product.stock) {
                    setState(() {
                      quantity++;
                    });
                  } else {
                    TLoaders.warningSnackBar(
                      title: 'Stock Limit',
                      message: 'Only ${widget.product.stock} items available',
                    );
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(width: TSizes.spaceBtwItems),
          
          // Add to Cart Button
          Expanded(
            child: GetBuilder<ProductAttributeController>(
              builder: (attributeController) {
                // Check if required attributes are selected
                final hasRequiredAttributes = widget.product.attributes.isEmpty || 
                    attributeController.selectedAttributes.isNotEmpty;
                
                return ElevatedButton(
                  onPressed: widget.product.isInStock && !isAddingToCart && hasRequiredAttributes
                      ? () => _addToCart(cartController, attributeController)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(TSizes.md),
                    backgroundColor: widget.product.isInStock && hasRequiredAttributes 
                        ? TColors.primary 
                        : Colors.grey,
                    side: BorderSide(
                      color: widget.product.isInStock && hasRequiredAttributes 
                          ? TColors.primary 
                          : Colors.grey,
                    ),
                  ),
                  child: isAddingToCart 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getButtonText(hasRequiredAttributes),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (quantity > 1) ...[
                              const SizedBox(height: 2),
                              Text(
                                '$quantity items',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(CartController cartController, ProductAttributeController attributeController) async {
    setState(() {
      isAddingToCart = true;
    });
    
    try {
      // Get selected attributes
      final selectedAttributes = attributeController.getSelectedAttributes();
      
      await cartController.addToCart(
        widget.product, 
        quantity: quantity,
        selectedAttributes: selectedAttributes.isNotEmpty ? selectedAttributes : null,
      );
      
      // Reset quantity after successful add
      setState(() {
        quantity = 1;
      });
      
      // Show success message with details
      final attributeText = selectedAttributes.isNotEmpty 
          ? ' (${selectedAttributes.values.join(', ')})'
          : '';
      
      TLoaders.successSnackBar(
        title: 'Added to Cart!',
        message: '${widget.product.title}$attributeText added successfully',
      );
      
    } catch (e) {
      // Error is handled by CartController
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  String _getButtonText(bool hasRequiredAttributes) {
    if (!widget.product.isInStock) {
      return 'Out of Stock';
    }
    
    if (!hasRequiredAttributes) {
      return 'Select Options';
    }
    
    if (quantity == 1) {
      return 'Add to Cart';
    }
    
    return 'Add $quantity to Cart';
  }
}


