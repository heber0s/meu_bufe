import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';

class ServicosController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final servicos = <Servico>[].obs;
  final carregando = false.obs;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    carregando.value = true;

    try {
      final resultado = await (db.select(db.servicos)
            ..orderBy([
              (servico) => OrderingTerm(
                    expression: servico.nome,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

      servicos.assignAll(resultado);
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os serviços.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      carregando.value = false;
    }
  }

  Future<void> salvar({
    int? id,
    required String nome,
    required String precoTexto,
    required String tipoCobranca,
    required bool ativo,
  }) async {
    final nomeLimpo = nome.trim();

    if (nomeLimpo.isEmpty) {
      Get.snackbar(
        'Campo obrigatório',
        'Informe o nome do serviço.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final preco = _centavosDoTexto(precoTexto);

    try {
      if (id == null) {
        await db.into(db.servicos).insert(
              ServicosCompanion.insert(
                nome: nomeLimpo,
                precoCentavos: Value(precoTexto.trim().isEmpty ? null : preco),
                tipoCobranca: Value(tipoCobranca),
                ativo: Value(ativo),
              ),
            );
      } else {
        await (db.update(db.servicos)..where((servico) => servico.id.equals(id)))
            .write(
          ServicosCompanion(
            nome: Value(nomeLimpo),
            precoCentavos: Value(precoTexto.trim().isEmpty ? null : preco),
            tipoCobranca: Value(tipoCobranca),
            ativo: Value(ativo),
          ),
        );
      }

      await carregar();
      Get.back();

      Get.snackbar(
        'Pronto',
        id == null ? 'Serviço cadastrado.' : 'Serviço atualizado.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar o serviço: $erro',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> alternarAtivo(Servico servico) async {
    try {
      await (db.update(db.servicos)
            ..where((linha) => linha.id.equals(servico.id)))
          .write(
        ServicosCompanion(ativo: Value(!servico.ativo)),
      );

      await carregar();
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o serviço.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int _centavosDoTexto(String texto) {
    final numeros = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numeros) ?? 0;
  }
}