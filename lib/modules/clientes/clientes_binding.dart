import 'package:get/get.dart';
import 'clientes_controller.dart';

class ClientesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientesController(), fenix: true);
  }
}