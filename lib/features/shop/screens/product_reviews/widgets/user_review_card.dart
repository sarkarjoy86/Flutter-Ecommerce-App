import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import 'package:readmore/readmore.dart';

import '../../../../../common/widgets/product_cards/rating/rating_indicator.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/review_model.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({
    Key? key,
    required this.review,
    this.onEdit,
    this.onDelete,
    this.isCurrentUserReview = false,
  }) : super(key: key);

  final ReviewModel review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCurrentUserReview;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isCurrentUserReview 
            ? (dark ? TColors.primary.withOpacity(0.1) : TColors.primary.withOpacity(0.05))
            : (dark ? TColors.darkerGrey : TColors.light),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: isCurrentUserReview 
              ? TColors.primary.withOpacity(0.5)
              : (dark ? TColors.darkGrey : TColors.grey.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: review.userProfileImage.isNotEmpty
                          ? NetworkImage(review.userProfileImage)
                          : const AssetImage(TImages.userProfileImage1) as ImageProvider,
                      onBackgroundImageError: review.userProfileImage.isNotEmpty
                          ? (exception, stackTrace) => const AssetImage(TImages.userProfileImage1)
                          : null,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  review.userName.isNotEmpty ? review.userName : 'Anonymous User',
                                  style: Theme.of(context).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (review.isVerifiedPurchase) ...[
                                const SizedBox(width: TSizes.spaceBtwItems / 2),
                                const Icon(
                                  Iconsax.verify5,
                                  color: TColors.primary,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: TSizes.spaceBtwItems / 2,
                            children: [
                              if (review.isVerifiedPurchase)
                                Text(
                                  'Verified User',
                                  style: Theme.of(context).textTheme.bodySmall?.apply(
                                        color: TColors.primary,
                                      ),
                                ),
                              if (isCurrentUserReview)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: TColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Your Review',
                                    style: Theme.of(context).textTheme.bodySmall?.apply(
                                          color: Colors.white,
                                          fontSizeDelta: -1,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action Menu for user's own reviews
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Iconsax.edit),
                            SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text('Edit Review'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, color: Colors.red),
                            SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text('Delete Review', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
            ],
          ),
          
          const SizedBox(height: TSizes.spaceBtwItems),
          
          // Rating and Date Row
          Row(
            children: [
              Flexible(
                child: TRatingBarIndicator(rating: review.rating),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Flexible(
                child: Text(
                  review.formattedReviewDate,
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: TColors.darkGrey,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TSizes.spaceBtwItems),
          
          // Review Text
          ReadMoreText(
            review.reviewText,
            trimLines: 3,
            trimMode: TrimMode.Line,
            trimExpandedText: ' show less',
            trimCollapsedText: ' show more',
            moreStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
            lessStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
