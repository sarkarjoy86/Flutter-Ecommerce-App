import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/features/authentication/controllers/onboarding_controller.dart';
import 'package:priyorong/features/authentication/screens/onboarding/widgets/onbaording_next_button.dart';
import 'package:priyorong/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:priyorong/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:priyorong/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:priyorong/utils/constants/image_strings.dart';
import 'package:priyorong/utils/constants/text_strings.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          // Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitile: TTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle2,
                subTitile: TTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage3,
                title: TTexts.onBoardingTitle3,
                subTitile: TTexts.onBoardingSubTitle3,
              )
            ],
          ),

          // Skip Button
          const OnBoardingSkip(),

          // Dot Navigation
          const OnBoardingDotNavigation(),

          // Circular Button
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}


