import 'package:get/get.dart';

import 'servicos_controller.dart';

class ServicosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicosController>(() => ServicosController());
  }
}