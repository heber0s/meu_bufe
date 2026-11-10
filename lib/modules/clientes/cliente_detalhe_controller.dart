import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';
import '../orcamentos/orcamento_totais.dart';
import 'cliente_form_sheet.dart';

class OrcamentoClienteResumo {
  const OrcamentoClienteResumo({
    required this.orcamento,
    required this.totalCentavos,
  });

  final Orcamento orcamento;
  final int totalCentavos;
}

class ClienteDetalheController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final cliente = Rxn<Cliente>();
  final orcamentos = <OrcamentoClienteResumo>[].obs;
  final carregando = true.obs;
  final erro = false.obs;

  StreamSubscription<List<Cliente>>? _clienteSubscription;
  StreamSubscription<List<Orcamento>>? _orcamentosSubscription;
  StreamSubscription<List<OrcamentoIten>>? _itensSubscription;
  int _versaoCarga = 0;

  int get clienteId {
    final valor = Get.parameters['id'];
    return int.tryParse(valor ?? '') ?? 0;
  }

  int get quantidadeOrcamentos => orcamentos.length;

  int get totalAprovadoCentavos => orcamentos
      .where((item) => item.orcamento.status.toLowerCase() == 'aprovado')
      .fold(0, (total, item) => total + item.totalCentavos);

  int get totalEmAbertoCentavos => orcamentos
      .where((item) {
        final status = item.orcamento.status.toLowerCase();
        return status != 'aprovado' && status != 'perdido';
      })
      .fold(0, (total, item) => total + item.totalCentavos);

  @override
  void onInit() {
    super.onInit();
    if (clienteId <= 0) {
      carregando.value = false;
      erro.value = true;
      return;
    }

    _clienteSubscription = (db.select(db.clientes)
          ..where((c) => c.id.equals(clienteId)))
        .watch()
        .listen((lista) {
      cliente.value = lista.isEmpty ? null : lista.first;
      if (lista.isEmpty) erro.value = true;
    }, onError: (_) => erro.value = true);

    _orcamentosSubscription = (db.select(db.orcamentos)
          ..where((o) => o.clienteId.equals(clienteId)))
        .watch()
        .listen((_) => _carregarDados(), onError: (_) => erro.value = true);

    _itensSubscription = db.select(db.orcamentoItens).watch().listen(
      (_) => _carregarDados(),
      onError: (_) => erro.value = true,
    );

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final versao = ++_versaoCarga;
    try {
      final listaOrcamentos = await (db.select(db.orcamentos)
            ..where((o) => o.clienteId.equals(clienteId))
            ..orderBy([
              (o) => OrderingTerm(
                    expression: o.dataEvento,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

      final ids = listaOrcamentos.map((o) => o.id).toList();
      final itens = ids.isEmpty
          ? <OrcamentoIten>[]
          : await (db.select(db.orcamentoItens)
                ..where((item) => item.orcamentoId.isIn(ids)))
              .get();

      final itensPorOrcamento = <int, List<OrcamentoIten>>{};
      for (final item in itens) {
        itensPorOrcamento.putIfAbsent(item.orcamentoId, () => []).add(item);
      }

      final resumos = listaOrcamentos.map((orcamento) {
        final totais = OrcamentoTotais.calcular(
          orcamento: orcamento,
          itens: itensPorOrcamento[orcamento.id] ?? const [],
        );
        return OrcamentoClienteResumo(
          orcamento: orcamento,
          totalCentavos: totais.totalCentavos,
        );
      }).toList();

      if (versao != _versaoCarga) return;
      orcamentos.assignAll(resumos);
      erro.value = false;
    } catch (_) {
      if (versao == _versaoCarga) erro.value = true;
    } finally {
      if (versao == _versaoCarga) carregando.value = false;
    }
  }

  Future<void> editarCliente() async {
    final clienteAtual = cliente.value;
    if (clienteAtual == null) return;

    final resultado = await Get.bottomSheet<ClienteFormResultado>(
      ClienteFormSheet(
        editando: true,
        nome: clienteAtual.nome,
        telefone: clienteAtual.telefone ?? '',
        email: clienteAtual.email ?? '',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (resultado == null) return;

    try {
      await (db.update(db.clientes)
            ..where((c) => c.id.equals(clienteAtual.id)))
          .write(
        ClientesCompanion(
          nome: Value(resultado.nome),
          telefone: Value(
            resultado.telefone.isEmpty ? null : resultado.telefone,
          ),
          email: Value(resultado.email.isEmpty ? null : resultado.email),
        ),
      );

      Get.snackbar(
        'Cliente atualizado',
        'Os dados de ${resultado.nome} foram salvos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar os dados do cliente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _clienteSubscription?.cancel();
    _orcamentosSubscription?.cancel();
    _itensSubscription?.cancel();
    super.onClose();
  }

  static String formatarMoeda(int centavos) {
    final reais = centavos ~/ 100;
    final centavosRestantes = (centavos % 100).abs().toString().padLeft(2, '0');
    final parteInteira = reais.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final sinal = centavos < 0 ? '-' : '';
    return 'R\$ $sinal$parteInteira,$centavosRestantes';
  }

  static String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  static String rotuloStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return 'Aprovado';
      case 'perdido':
        return 'Perdido';
      case 'enviado':
        return 'Enviado';
      case 'negociacao':
      case 'em_negociacao':
        return 'Em negociação';
      case 'pendente':
        return 'Pendente';
      default:
        if (status.isEmpty) return 'Sem status';
        return status[0].toUpperCase() + status.substring(1);
    }
  }
}
