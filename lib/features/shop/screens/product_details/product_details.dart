import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/bottom_add_to_cart.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/product_metaData.dart';
import 'package:priyorong/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:priyorong/features/shop/screens/product_reviews/product_revies.dart';
import 'package:priyorong/features/shop/models/product_model.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:priyorong/data/repositories/products/product_repository.dart';

import '../../../../common/widgets/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';


import '../checkout/checkout.dart';


class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    // Listen to Firestore for instant updates
    final productDocStream = FirebaseFirestore.instance
        .collection('Products')
        .doc(product.id)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: productDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Product not found.')),
          );
        }
        final updatedProduct = ProductModel.fromSnapshot(snapshot.data!);
        return Scaffold(
          bottomNavigationBar: TBottomAddToCart(product: updatedProduct),
          body: SingleChildScrollView(
            child: Column(
              children: [
                /// 1 - Product Image Slider with curved background
                TProductImageSlider(product: updatedProduct),

                /// 2 - Product Details
                Padding(
                  padding: const EdgeInsets.only(
                    right: TSizes.defaultSpace,
                    left: TSizes.defaultSpace,
                    bottom: TSizes.defaultSpace,
                  ),
                  child: Column(
                    children: [
                      /// Rating & Share Button
                      TRatingAndShare(product: updatedProduct),

                      /// Price, Title, Stock, & Brand
                      TProductMetaData(product: updatedProduct),

                      /// Add spacing before attributes
                      const SizedBox(height: TSizes.spaceBtwSections),
                      
                      /// Attributes
                      TProductAttributes(product: updatedProduct),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // Checkout Button
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                final attrController = Get.find<ProductAttributeController>();
                                final selectedSize = attrController.selectedSize.value;
                                if (updatedProduct.attributes.containsKey('Size') && selectedSize.isEmpty) {
                                  Get.snackbar('Select Size', 'Please select a size before checkout.', snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                Get.to(() => CheckoutScreen(
                                  directProduct: updatedProduct,
                                  directQuantity: 1,
                                  selectedSize: selectedSize.isNotEmpty ? selectedSize : null,
                                ));
                              },
                              child: const Text('Checkout'))),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // Description
                      const TSectionHeading(
                          title: 'Description', showActionButton: false),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ReadMoreText(
                        updatedProduct.description.isNotEmpty 
                            ? updatedProduct.description 
                            : 'No description available for this product.',
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Less',
                        moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ), // ReadMoreText

                      // Reviews
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TSectionHeading(
                              title: 'Reviews',
                              showActionButton: false),
                          IconButton(
                              icon: const Icon(Iconsax.arrow_right_3, size: 18),
                              onPressed: () =>
                                  Get.to(() => ProductReviewsScreen(product: updatedProduct))),
                        ],
                      ), // Row
                      const SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
