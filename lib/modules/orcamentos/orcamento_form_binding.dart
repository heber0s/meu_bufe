import 'package:get/get.dart';
import '../clientes/clientes_controller.dart';
import 'orcamento_controller.dart';

class OrcamentoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrcamentoController>(() => OrcamentoController());
    // fenix: garante a lista de clientes mesmo se a aba já tiver sido descartada
    Get.lazyPut<ClientesController>(() => ClientesController(), fenix: true);
  }
}