import 'package:get/get.dart';

import 'cliente_detalhe_controller.dart';

class ClienteDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClienteDetalheController());
  }
}
