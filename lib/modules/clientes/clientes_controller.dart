import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';
import 'cliente_form_sheet.dart';

class ClientesController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final clientes = <Cliente>[].obs;
  final busca = ''.obs;
  final carregando = true.obs;
  final salvando = false.obs;
  final filtroOrcamentos = 'todos'.obs;
  final orcamentosPorCliente = <int, int>{}.obs;

  StreamSubscription<List<Cliente>>? _subscription;
  StreamSubscription<List<Orcamento>>? _orcamentosSubscription;

  int get quantidadeComOrcamento =>
      clientes.where((cliente) => orcamentosDoCliente(cliente.id) > 0).length;

  int get quantidadeSemOrcamento => clientes.length - quantidadeComOrcamento;

  int orcamentosDoCliente(int clienteId) =>
      orcamentosPorCliente[clienteId] ?? 0;

  /// Busca por contato e segmentação reativa por vínculo com orçamentos.
  List<Cliente> get clientesFiltrados {
    final termo = _normalizar(busca.value);
    final filtro = filtroOrcamentos.value;

    return clientes.where((cliente) {
      final combinaBusca = termo.isEmpty ||
          _normalizar(cliente.nome).contains(termo) ||
          _normalizar(cliente.telefone ?? '').contains(termo) ||
          _normalizar(cliente.email ?? '').contains(termo);
      final possuiOrcamento = orcamentosDoCliente(cliente.id) > 0;
      final combinaFiltro = filtro == 'todos' ||
          (filtro == 'com_orcamento' && possuiOrcamento) ||
          (filtro == 'sem_orcamento' && !possuiOrcamento);
      return combinaBusca && combinaFiltro;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();

    // A lista é reativa: qualquer insert/update/delete atualiza a tela.
    _subscription = (db.select(db.clientes)
          ..orderBy([(c) => OrderingTerm(expression: c.nome)]))
        .watch()
        .listen(
      (lista) {
        clientes.assignAll(lista);
        carregando.value = false;
      },
      onError: (Object _) {
        carregando.value = false;
        Get.snackbar(
          'Erro',
          'Não foi possível carregar os clientes.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    _orcamentosSubscription = db.select(db.orcamentos).watch().listen(
      (lista) {
        final contagens = <int, int>{};
        for (final orcamento in lista) {
          contagens.update(
            orcamento.clienteId,
            (quantidade) => quantidade + 1,
            ifAbsent: () => 1,
          );
        }
        orcamentosPorCliente.assignAll(contagens);
      },
      onError: (_) => Get.snackbar(
        'Erro',
        'Não foi possível atualizar os vínculos dos orçamentos.',
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _orcamentosSubscription?.cancel();
    super.onClose();
  }

  /// Sem [cliente] cadastra; com [cliente] edita.
  /// O formulário é um StatefulWidget que cuida dos próprios controllers,
  /// então aqui não existe nenhum TextEditingController para descartar.
  Future<void> abrirFormulario({Cliente? cliente}) async {
    final resultado = await Get.bottomSheet<ClienteFormResultado>(
      ClienteFormSheet(
        editando: cliente != null,
        nome: cliente?.nome ?? '',
        telefone: cliente?.telefone ?? '',
        email: cliente?.email ?? '',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (resultado == null) return;

    await _salvar(resultado, cliente);
  }

  Future<void> _salvar(ClienteFormResultado dados, Cliente? existente) async {
    if (salvando.value) return;
    salvando.value = true;

    try {
      // Campo vazio vira null, para o cartão não exibir linhas em branco.
      final companion = ClientesCompanion(
        nome: Value(dados.nome),
        telefone: Value(dados.telefone.isEmpty ? null : dados.telefone),
        email: Value(dados.email.isEmpty ? null : dados.email),
      );

      if (existente == null) {
        await db.into(db.clientes).insert(companion);
      } else {
        await (db.update(db.clientes)
              ..where((c) => c.id.equals(existente.id)))
            .write(companion);
      }

      Get.snackbar(
        existente == null ? 'Cliente cadastrado' : 'Cliente atualizado',
        dados.nome,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar o cliente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      salvando.value = false;
    }
  }

  Future<void> excluirCliente(Cliente cliente) async {
    // Evita apagar cliente que ainda tem orçamentos vinculados.
    // Ajuste `clienteId` se a coluna de Orcamentos tiver outro nome.
    final vinculados = await (db.select(db.orcamentos)
          ..where((o) => o.clienteId.equals(cliente.id))
          ..limit(1))
        .get();

    if (vinculados.isNotEmpty) {
      Get.snackbar(
        'Cliente com orçamentos',
        'Exclua ou altere os orçamentos deste cliente antes de removê-lo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await (db.delete(db.clientes)..where((c) => c.id.equals(cliente.id)))
          .go();

      Get.snackbar(
        'Cliente removido',
        cliente.nome,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível excluir o cliente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Minúsculas e sem acentos, para a busca não depender disso.
  String _normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

    var resultado = texto.trim().toLowerCase();
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }
}