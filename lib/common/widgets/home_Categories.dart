import 'package:flutter/material.dart';
import 'package:priyorong/common/widgets/vertical_image_text_widgets.dart';

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
            image: TImages.shoeIcon,
            title: 'Shoes',
            onTap: () {},
          );
        },
      ),
    );
  }
}

