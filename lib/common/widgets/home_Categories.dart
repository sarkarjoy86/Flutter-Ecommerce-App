import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyorong/common/widgets/vertical_image_text_widgets.dart';
import 'package:priyorong/features/shop/screens/sub_category/sub_categories.dart';

import '../../features/shop/controllers/category_controller.dart';
import '../../utils/constants/image_strings.dart';
import 'category_shimmer.dart';

class ThomeCategories extends StatelessWidget {
  const ThomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = CategoryController.instance;

    return Obx(() {
      if (categoryController.isLoading.value) return const CategoryShimmer();

      if (categoryController.featuredCategories.isEmpty) {
        return Center(
          child: Column(
            children: [
              Text(
                'No Categories Found!',
                style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => categoryController.refreshCategories(),
                child: Text(
                  'Tap to Refresh',
                  style: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        height: 80,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categoryController.featuredCategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final category = categoryController.featuredCategories[index];
            return TVerticalImageText(
              image: category.image,
              title: category.name,
              onTap: () => Get.to(() => SubCategoriesScreen(category: category)),
            );
          },
        ),
      );
    });
  }
}
