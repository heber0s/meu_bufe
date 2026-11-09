import 'package:get/get.dart';
import 'orcamento_detalhe_controller.dart';

class OrcamentoDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrcamentoDetalheController());
  }
}