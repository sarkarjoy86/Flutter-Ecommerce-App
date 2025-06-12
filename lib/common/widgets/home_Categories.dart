import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:priyorong/common/widgets/vertical_image_text_widgets.dart';
import 'package:priyorong/features/shop/screens/sub_category/sub_categories.dart';

import '../../utils/constants/image_strings.dart';
class THome_Categories extends StatelessWidget {
  const THome_Categories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return TVerticalImageText(
            image: TImages.clothIcon,
            title: 'Khadi Panjabi',
            onTap: () => Get.to(()=> const SubCategoriesScreen()),
          );
        },
      ),
    );
  }
}

