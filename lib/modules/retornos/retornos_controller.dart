import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../core/services/notificacao_service.dart';
import '../../data/database/app_database.dart';
import '../../routes/app_routes.dart';

// Filtros disponíveis na central de retornos.
enum FiltroRetorno { todos, atrasados, hoje, proximos }

class RetornoOrcamento {
  const RetornoOrcamento({
    required this.orcamentoId,
    required this.titulo,
    required this.cliente,
    required this.status,
    required this.resumo,
    required this.canal,
    required this.contatoEm,
    required this.quando,
  });

  final int orcamentoId;
  final String titulo;
  final String cliente;
  final String status;
  final String resumo;
  final String canal;
  final DateTime contatoEm;
  final DateTime quando;

  bool get hoje {
    final agora = DateTime.now();
    return quando.year == agora.year &&
        quando.month == agora.month &&
        quando.day == agora.day;
  }

  bool get atrasado {
    final agora = DateTime.now();
    final dataRetorno = DateTime(quando.year, quando.month, quando.day);
    final dataHoje = DateTime(agora.year, agora.month, agora.day);
    return dataRetorno.isBefore(dataHoje);
  }

  factory RetornoOrcamento.fromRow(QueryRow row) {
    return RetornoOrcamento(
      orcamentoId: row.read<int>('orcamento_id'),
      titulo: row.read<String>('titulo'),
      cliente: row.read<String>('cliente_nome'),
      status: row.read<String>('status'),
      resumo: row.read<String>('resumo'),
      canal: row.read<String>('canal'),
      contatoEm: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('contato_em'),
      ),
      quando: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('proximo_retorno'),
      ),
    );
  }
}

class RetornosController extends GetxController {
  RetornosController({AppDatabase? database})
      : db = database ?? Get.find<AppDatabase>();

  final AppDatabase db;
  final retornos = <RetornoOrcamento>[].obs;
  final filtro = FiltroRetorno.todos.obs;
  final busca = ''.obs;
  final carregando = false.obs;
  final erro = RxnString();

  List<RetornoOrcamento> get retornosVisiveis {
    final porCategoria = retornos.where((item) {
      switch (filtro.value) {
        case FiltroRetorno.atrasados:
          return item.atrasado;
        case FiltroRetorno.hoje:
          return item.hoje;
        case FiltroRetorno.proximos:
          return !item.atrasado && !item.hoje;
        case FiltroRetorno.todos:
          return true;
      }
    });

    final termo = busca.value.trim().toLowerCase();
    if (termo.isEmpty) return porCategoria.toList();

    return porCategoria.where((item) {
      final campos = [
        item.cliente,
        item.titulo,
        item.resumo,
        item.canal,
        item.status,
      ].join(' ').toLowerCase();
      return campos.contains(termo);
    }).toList();
  }

  Map<FiltroRetorno, List<RetornoOrcamento>> get retornosAgrupadosVisiveis {
    final lista = retornosVisiveis;
    return {
      FiltroRetorno.atrasados:
          lista.where((item) => item.atrasado).toList(),
      FiltroRetorno.hoje: lista.where((item) => item.hoje).toList(),
      FiltroRetorno.proximos:
          lista.where((item) => !item.atrasado && !item.hoje).toList(),
    };
  }

  void atualizarBusca(String valor) => busca.value = valor;

  int get quantidadeAtrasados => retornos.where((item) => item.atrasado).length;
  int get quantidadeHoje => retornos.where((item) => item.hoje).length;
  int get quantidadeProximos =>
      retornos.where((item) => !item.atrasado && !item.hoje).length;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar({bool silencioso = false}) async {
    if (carregando.value) return;
    if (!silencioso) carregando.value = true;
    erro.value = null;

    try {
      final linhas = await db.customSelect('''
        SELECT atual.orcamento_id,
               atual.proximo_retorno,
               atual.resumo,
               atual.canal,
               atual.contato_em,
               o.titulo,
               o.status,
               c.nome AS cliente_nome
        FROM orcamento_acompanhamentos atual
        JOIN (
          SELECT orcamento_id, MAX(id) AS ultimo_id
          FROM orcamento_acompanhamentos
          GROUP BY orcamento_id
        ) ultimos ON ultimos.ultimo_id = atual.id
        JOIN orcamentos o ON o.id = atual.orcamento_id
        JOIN clientes c ON c.id = o.cliente_id
        WHERE atual.proximo_retorno IS NOT NULL
          AND LOWER(TRIM(o.status)) NOT IN ('aprovado', 'perdido')
        ORDER BY atual.proximo_retorno ASC, atual.id DESC
      ''').get();

      retornos.assignAll(linhas.map(RetornoOrcamento.fromRow));
    } catch (_) {
      erro.value = 'Não foi possível carregar os retornos. Tente novamente.';
      Get.snackbar(
        'Erro ao carregar',
        erro.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      carregando.value = false;
    }
  }

  void selecionarFiltro(FiltroRetorno valor) => filtro.value = valor;

  Future<void> abrirOrcamento(RetornoOrcamento retorno) async {
    await Get.toNamed(Routes.detalhe(retorno.orcamentoId));
    await carregar(silencioso: true);
  }

  Future<void> concluirRetorno(RetornoOrcamento retorno) async {
    final confirmado = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Concluir retorno?'),
        content: Text(
          'O retorno de ${retorno.cliente} será marcado como concluído. '
          'O registro atual será preservado no histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Concluir'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (confirmado != true) return;

    try {
      await db.customStatement(
        '''
        INSERT INTO orcamento_acompanhamentos
          (orcamento_id, contato_em, canal, resumo, proximo_retorno)
        VALUES (?, ?, ?, ?, NULL)
        ''',
        [
          retorno.orcamentoId,
          DateTime.now().millisecondsSinceEpoch,
          retorno.canal,
          'Retorno concluído na Central de Retornos.',
        ],
      );

      var notificacaoFalhou = false;
      if (Get.isRegistered<NotificacaoService>()) {
        try {
          await Get.find<NotificacaoService>()
              .cancelarRetorno(retorno.orcamentoId);
        } catch (_) {
          notificacaoFalhou = true;
        }
      }

      await carregar(silencioso: true);
      Get.snackbar(
        'Retorno concluído',
        notificacaoFalhou
            ? 'O histórico foi preservado, mas não foi possível cancelar a notificação.'
            : 'O contato foi registrado no histórico.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro ao concluir',
        'Não foi possível registrar a conclusão do retorno.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> reagendarRetorno(
    RetornoOrcamento retorno,
    DateTime novoRetorno,
  ) async {
    if (!novoRetorno.isAfter(DateTime.now())) {
      Get.snackbar(
        'Data inválida',
        'Escolha uma data e um horário futuros.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await db.customStatement(
        '''
        INSERT INTO orcamento_acompanhamentos
          (orcamento_id, contato_em, canal, resumo, proximo_retorno)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          retorno.orcamentoId,
          DateTime.now().millisecondsSinceEpoch,
          retorno.canal,
          'Retorno reagendado na Central de Retornos.',
          novoRetorno.millisecondsSinceEpoch,
        ],
      );

      var notificacaoFalhou = false;
      if (Get.isRegistered<NotificacaoService>()) {
        try {
          await Get.find<NotificacaoService>().agendarRetorno(
            orcamentoId: retorno.orcamentoId,
            titulo: retorno.titulo,
            cliente: retorno.cliente,
            resumo: 'Retorno reagendado.',
            quando: novoRetorno,
          );
        } catch (_) {
          notificacaoFalhou = true;
        }
      }

      await carregar(silencioso: true);
      Get.snackbar(
        'Retorno reagendado',
        notificacaoFalhou
            ? 'A nova data foi salva no histórico, mas não foi possível atualizar a notificação.'
            : 'Novo horário: ${formatarDataHora(novoRetorno)}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro ao reagendar',
        'Não foi possível salvar a nova data do retorno.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} · '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}
