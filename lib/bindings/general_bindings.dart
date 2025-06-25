import 'package:get/get.dart';

import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager()); // This injects NetworkManager into the Get dependency system
  }
}
