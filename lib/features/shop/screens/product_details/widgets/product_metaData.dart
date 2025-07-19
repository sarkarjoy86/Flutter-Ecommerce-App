import 'package:flutter/material.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:priyorong/common/widgets/texts/product_title_text.dart';
import 'package:priyorong/features/shop/models/product_model.dart';

import '../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../common/widgets/texts/brandTitleWithvarified_icon.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TProductMetaData extends StatelessWidget {
  const TProductMetaData({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price & Sale Price
        Row(
          children: [
            // Sale Tag - Only show if on sale
            if (product.isOnSale) ...[
              CircularContainer(
                radius: TSizes.sm,
                backgroundColor: Colors.yellow.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.sm,
                  vertical: TSizes.xs,
                ),
                child: Text(
                  '${product.discountPercentage.toInt()}%',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(color: TColors.black),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
            ],

            // Old Price - Only show if on sale
            if (product.isOnSale) ...[
              Text(
                '৳${product.price.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .apply(decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
            ],

            // Current/Sale Price
            Text(
              '৳${product.actualPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        // Title
        Text(
          product.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        // Stock Status
        Row(
          children: [
            const TProductTitleText(title: 'Status'),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              product.isInStock ? 'In Stock (${product.stock})' : 'Out of Stock',
              style: Theme.of(context).textTheme.titleMedium!.apply(
                color: product.isInStock ? Colors.green : Colors.red,
              ),
            ),
          ], // Row
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        // SKU
        Row(
          children: [
            const TProductTitleText(title: 'SKU'),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              product.sku.isNotEmpty ? product.sku : 'N/A',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),

        // Brand - Only show if brand exists
        if (product.brandId != null && product.brandId!.isNotEmpty) ...[
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),
          Row(
            children: [
              TCircularImage(
                image: TImages.clothIcon, // You might want to get actual brand logo
                width: 32,
                height: 32,
                overlayColor: darkMode ? TColors.white : TColors.black,
              ),
              const TBrandTitleWithVerifiedIcon(
                title: 'Brand', // You might want to get actual brand name
                brandTextSize: TextSizes.medium,
              ),
            ],
          ), // Row
        ],
      ],
    );
  }
}
