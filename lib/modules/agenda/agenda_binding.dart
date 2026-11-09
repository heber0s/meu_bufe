import 'package:get/get.dart';
import 'agenda_controller.dart';

class AgendaBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true recria o controller se ele já tiver sido descartado
    // (útil porque a agenda também vive como aba da Home).
    Get.lazyPut(() => AgendaController(), fenix: true);
  }
}