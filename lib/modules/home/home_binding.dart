import 'package:get/get.dart';

import '../agenda/agenda_controller.dart';
import '../clientes/clientes_controller.dart';
import '../orcamentos/orcamentos_lista_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    Get.lazyPut<OrcamentosListaController>(
      () => OrcamentosListaController(),
      fenix: true,
    );

    Get.lazyPut<AgendaController>(
      () => AgendaController(),
      fenix: true,
    );

    Get.lazyPut<ClientesController>(
      () => ClientesController(),
      fenix: true,
    );
  }
}