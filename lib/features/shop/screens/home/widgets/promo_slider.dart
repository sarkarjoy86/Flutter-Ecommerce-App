import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/features/shop/controllers/home_controlller.dart';
import 'package:priyorong/utils/constants/colors.dart';

import '../../../../../common/widgets/circular_container_shape.dart';
import '../../../../../common/widgets/t_rounded_image.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';

class THomeSlider extends StatelessWidget {
  const THomeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: const [
            TRoundedImage(imageUrl: TImages.banner6),
            TRoundedImage(imageUrl: TImages.banner8),
            TRoundedImage(imageUrl: TImages.banner7),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
              () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (i) => CircularContainer(
                width: 20,
                height: 4,
                margin: const EdgeInsets.only(right: 10),
                backgroundColor: controller.carousalCurrentIndex.value == i
                    ? TColors.primary
                    : TColors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
