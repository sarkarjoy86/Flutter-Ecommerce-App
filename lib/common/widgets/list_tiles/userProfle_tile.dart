import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/t_circular_image.dart';


class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return ListTile(
      leading: Obx(() {
        final networkImage = controller.user.value.profilePicture;
        final image = networkImage.isNotEmpty ? networkImage : TImages.user;
        return TCircularImage(
          image: image,
          width: 50,
          height: 50,
          padding: 0,
          isNetworkImage: networkImage.isNotEmpty,
        );
      }),
      title: Obx(
        () => Text(
          controller.user.value.fullName,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: TColors.white),
        ),
      ),
      subtitle: Obx(
        () => Text(
          controller.user.value.email,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .apply(color: TColors.white),
        ),
      ),
      trailing: IconButton(
        onPressed: onPressed,
        icon: const Icon(Iconsax.edit, color: TColors.white),
      ),
    );
  }
}