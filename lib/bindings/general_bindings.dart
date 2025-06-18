import 'package:get/get.dart';

import '../features/authentication/controllers/neywork_manager.dart';
 // Ensure the correct import path

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager()); // This injects NetworkManager into the Get dependency system
  }
}
