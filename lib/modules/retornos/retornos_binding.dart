import 'package:get/get.dart';

import 'retornos_controller.dart';

class RetornosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RetornosController>(() => RetornosController());
  }
}
