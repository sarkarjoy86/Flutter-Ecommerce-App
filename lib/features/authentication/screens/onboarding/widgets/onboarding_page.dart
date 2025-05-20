import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitile,
  });

  final String image, title, subTitile;

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      // Center everything in the screen
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Spacer to push content to center
          const Spacer(),
          
          // Image with fixed size from TSizes
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: TSizes.imageCarouselHeight,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;

                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: TSizes.iconLg,
                    color: isDark ? TColors.white : TColors.darkGrey,
                  ),
                );
              },
            ),
          ),
          
          // Space between image and title
          const SizedBox(height: TSizes.spaceBtwSections),
          
          // Title with center alignment
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          // Space between title and subtitle
          const SizedBox(height: TSizes.spaceBtwItems),
          
          // Subtitle with center alignment
          Text(
            subTitile,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          // Spacer to push content to center
          const Spacer(),
        ],
      ),
    );
  }
}