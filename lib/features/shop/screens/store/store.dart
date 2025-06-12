import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:priyorong/common/widgets/appbar/appbar.dart';
import 'package:priyorong/common/widgets/appbar/tabbar.dart';
import 'package:priyorong/common/widgets/cart_menu_icon.dart';
import 'package:priyorong/common/widgets/layouts/grid_layout.dart';
import 'package:priyorong/common/widgets/search_bar.dart';
import 'package:priyorong/common/widgets/section_heading.dart';
import 'package:priyorong/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/catagory_tab.dart';
import '../../../../common/widgets/brand/t_brand_card.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../brand/all_brands.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Store',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCartCounterIcon(onPressed: () {}),
          ],
        ),
        body: NestedScrollView(
            headerSliverBuilder: (_, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: true,
                    backgroundColor: THelperFunctions.isDarkMode(context)
                        ? TColors.black
                        : TColors.white,
                    expandedHeight: 440,
                    flexibleSpace: Padding(
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            /// Search Bar
                            const SizedBox(height: TSizes.spaceBtwItems),
                            const TSearchContainer(
                              text: 'Search in Store',
                              showBorder: true,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),

                            /// Featured Brands
                            TSectionHeading(
                              title: 'Featured Brands',
                              onPressed: () => Get.to(() => const AllBrandsScreen()),
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                            TGridLayout(
                                itemCount: 4,
                                mainAxisExtent: 80,
                                itemBuilder: (_, index) {
                                  return TBrandCard(
                                    title: 'Sultan',
                                    image: TImages.clothIcon,
                                    productCount: '256 Products',
                                    showBorder: true,
                                    onTap: () {
                                      // Handle tap
                                    },
                                  );
                                })
                          ],
                        )),

                    /// Tabs\
                    bottom: const TTabBar(tabs: [
                      Tab(
                        child: Text('Khadi'),
                      ),
                      Tab(
                        child: Text('Embroidered'),
                      ),
                      Tab(
                        child: Text('HandPaint'),
                      ),
                      Tab(
                        child: Text('Sharee'),
                      ),
                      Tab(
                        child: Text('Kurta'),
                      ),
                    ])),
              ];
            },
            body: const TabBarView(children: [
              TCategoryTab(),
              TCategoryTab(),
              TCategoryTab(),
              TCategoryTab(),
              TCategoryTab(),
            ]
            ),
        ),
      ),
    );
  }
}
