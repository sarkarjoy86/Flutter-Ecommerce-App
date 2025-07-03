import 'package:get/get.dart';

import '../features/personalization/controllers/user_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager()); // This injects NetworkManager into the Get dependency system
    Get.put(UserController()); // This injects UserController into the Get dependency system
  }
}
