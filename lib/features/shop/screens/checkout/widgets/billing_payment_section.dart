import 'package:flutter/material.dart';
import 'package:priyorong/common/widgets/circular_container_shape.dart';
import '../../../../../common/widgets/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TBillingPaymentSection extends StatelessWidget {
  const TBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        TSectionHeading(
          title: 'Payment Method',
          buttonTitle: 'Change',
          onPressed: () {},
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Row(
          children: [
            CircularContainer(
              width: 60,
              height: 35,
              backgroundColor: dark ? TColors.light : TColors.white,
              padding: const EdgeInsets.all(TSizes.sm),
              child: const Image(
                image: AssetImage(TImages.visa),
                fit: BoxFit.contain,
              ),
            ), // TRoundedContainer
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Text('Debit Card', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
