import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/review_controller.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({
    super.key,
    required this.product,
    required this.isEditing,
    this.existingReview,
  });

  final ProductModel product;
  final bool isEditing;
  final ReviewModel? existingReview;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final reviewController = Get.find<ReviewController>();
  final userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    // If editing, populate with existing data
    if (widget.isEditing && widget.existingReview != null) {
      reviewController.prepareEditReview(widget.existingReview!);
    } else {
      reviewController.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(widget.isEditing ? '  Edit Review  ' : '  Write Review  '),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info
                _buildProductInfo(),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Rating Section
                _buildRatingSection(),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Review Text Section
                _buildReviewTextSection(),
                const SizedBox(height: TSizes.spaceBtwSections * 2),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: TColors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Product Image
          TRoundedImage(
            imageUrl: widget.product.bestDisplayImage,
            width: 60,
            height: 60,
            isNetworkImage: widget.product.bestDisplayImage.startsWith('http'),
            applyImageRadius: true,
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  '৳${widget.product.actualPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.apply(
                        color: TColors.primary,
                        fontWeightDelta: 2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Iconsax.star1,
              color: TColors.primary,
              size: 20,
            ),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Text(
              'Rate this product',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        
        Obx(() => Column(
          children: [
            RatingBar.builder(
              initialRating: reviewController.selectedRating.value,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                reviewController.selectedRating.value = rating;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            Text(
              _getRatingText(reviewController.selectedRating.value),
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                    color: TColors.primary,
                    fontWeightDelta: 2,
                  ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildReviewTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Iconsax.message_edit,
              color: TColors.primary,
              size: 20,
            ),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Text(
              'Write your review',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        
        TextFormField(
          controller: reviewController.reviewTextController,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this product...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write your review';
            }
            if (value.trim().length < 10) {
              return 'Review must be at least 10 characters long';
            }
            return null;
          },
        ),
        
        const SizedBox(height: TSizes.spaceBtwItems),
        
        // Review Guidelines
        Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    color: TColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  Text(
                    'Review Guidelines',
                    style: Theme.of(context).textTheme.bodyMedium?.apply(
                          color: TColors.primary,
                          fontWeightDelta: 2,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                '• Be honest and helpful\n• Focus on the product features\n• Avoid offensive language\n• Keep it relevant and constructive',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitReview,
        child: Text(widget.isEditing ? 'Update Review' : 'Submit Review'),
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this product';
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.isEditing && widget.existingReview != null) {
        // Update existing review
        await reviewController.updateReview(
          context,
          widget.existingReview!.id,
          widget.product,
        );
      } else {
        // Add new review
        await reviewController.submitReview(
          context,
          widget.product,
          userController.user.value.id,
          userController.user.value.fullName,
          userProfileImage: userController.user.value.profilePicture,
        );
      }
      
    } catch (e) {
      // Error handling is done in the controller
    }
  }
} 