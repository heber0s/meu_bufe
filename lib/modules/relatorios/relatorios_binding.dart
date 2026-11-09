import 'package:get/get.dart';

import 'relatorios_controller.dart';

class RelatoriosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatoriosController>(() => RelatoriosController());
  }
}
