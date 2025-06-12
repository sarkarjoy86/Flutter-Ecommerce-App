import 'package:flutter/material.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/progress_indicator_and_rating.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:priyorong/features/shop/screens/product_reviews/widgets/user_review_card.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/product_cards/rating/rating_indicator.dart';
import '../../../../utils/constants/sizes.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar:
          const TAppBar(title: Text('Reviews & Ratings'), showBackArrow: true),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ratings and reviews are verified and are from people who use the same type of device that you use.",
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              // Overall Product Ratings
              const TOverallProductRating(),

              const TRatingBarIndicator(
                rating: 3.5),
              Text(
                "12,611",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              // User Review List
              const UserReviewCard(),
              const UserReviewCard(),
              const UserReviewCard(),
            ],
          ), // Column
        ), // Padding
      ), // SingleChildScrollView
    ); // Scaffold
  }
}



