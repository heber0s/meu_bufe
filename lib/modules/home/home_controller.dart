// modules/home/home_controller.dart
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Índice da aba atual; a UI observa com Obx
  final abaAtual = 0.obs;

  void trocarAba(int index) => abaAtual.value = index;
}