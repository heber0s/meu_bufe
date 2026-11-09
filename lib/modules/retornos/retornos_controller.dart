import 'package:drift/drift.dart' hide Column;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';
import '../../routes/app_routes.dart';

// Filtros disponíveis na central de retornos.
enum FiltroRetorno { todos, atrasados, proximos }

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

  bool get atrasado => quando.isBefore(DateTime.now());

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
  final carregando = false.obs;
  final erro = RxnString();

  List<RetornoOrcamento> get retornosVisiveis {
    final lista = retornos.toList();
    switch (filtro.value) {
      case FiltroRetorno.atrasados:
        return lista.where((item) => item.atrasado).toList();
      case FiltroRetorno.proximos:
        return lista.where((item) => !item.atrasado).toList();
      case FiltroRetorno.todos:
        return lista;
    }
  }

  int get quantidadeAtrasados => retornos.where((item) => item.atrasado).length;
  int get quantidadeProximos => retornos.length - quantidadeAtrasados;

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

  String formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} · '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}
