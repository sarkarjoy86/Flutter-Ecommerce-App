import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/circular_container_shape.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';

class THomeSlider extends StatefulWidget {
  const THomeSlider({super.key});

  @override
  State<THomeSlider> createState() => _THomeSliderState();
}

class _THomeSliderState extends State<THomeSlider> {
  int currentIndex = 0;

  static const staticBanners = [
    TImages.banner6,
    TImages.banner8,
    TImages.banner7,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          items: staticBanners.map((banner) => TRoundedImage(imageUrl: banner)).toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            staticBanners.length,
            (i) => CircularContainer(
              width: 20,
              height: 4,
              margin: const EdgeInsets.only(right: 10),
              backgroundColor: currentIndex == i
                  ? TColors.primary
                  : TColors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
