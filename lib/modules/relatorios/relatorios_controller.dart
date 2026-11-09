import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';

enum PeriodoRelatorio { todos, mesAtual, ultimos30Dias, anoAtual, personalizado }

class OrcamentoRelatorio {
  OrcamentoRelatorio(this.orcamento, this.cliente, this.itens);

  final Orcamento orcamento;
  final Cliente cliente;
  final List<OrcamentoIten> itens;

  int get totalCentavos {
    final subtotal = itens.fold<int>(0, (soma, item) {
      final valor = switch (item.tipoCobranca) {
        'porConvidado' => item.precoCentavos * orcamento.convidados,
        'porUnidade' => item.precoCentavos * item.quantidade,
        _ => item.precoCentavos,
      };
      return soma + valor;
    });
    return math.max(0, subtotal - orcamento.descontoCentavos);
  }
}

class RelatoriosController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final orcamentos = <OrcamentoRelatorio>[].obs;
  final carregando = true.obs;
  final periodoSelecionado = PeriodoRelatorio.todos.obs;
  DateTime? _inicioPersonalizado;
  DateTime? _fimPersonalizado;
  StreamSubscription<List<OrcamentoRelatorio>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    final query = db.select(db.orcamentos).join([
      innerJoin(
        db.clientes,
        db.clientes.id.equalsExp(db.orcamentos.clienteId),
      ),
      leftOuterJoin(
        db.orcamentoItens,
        db.orcamentoItens.orcamentoId.equalsExp(db.orcamentos.id),
      ),
    ])..orderBy([OrderingTerm.desc(db.orcamentos.dataEvento)]);

    _subscription = query.watch().map((rows) {
      final agrupados = <int, OrcamentoRelatorio>{};
      for (final row in rows) {
        final orcamento = row.readTable(db.orcamentos);
        final cliente = row.readTable(db.clientes);
        final item = row.readTableOrNull(db.orcamentoItens);
        final resumo = agrupados.putIfAbsent(
          orcamento.id,
          () => OrcamentoRelatorio(orcamento, cliente, <OrcamentoIten>[]),
        );
        if (item != null) resumo.itens.add(item);
      }
      return agrupados.values.toList();
    }).listen((lista) {
      orcamentos.assignAll(lista);
      carregando.value = false;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  String get periodoLabel {
    switch (periodoSelecionado.value) {
      case PeriodoRelatorio.todos:
        return 'todo o período';
      case PeriodoRelatorio.mesAtual:
        return 'este mês';
      case PeriodoRelatorio.ultimos30Dias:
        return 'últimos 30 dias';
      case PeriodoRelatorio.anoAtual:
        return 'este ano';
      case PeriodoRelatorio.personalizado:
        if (_inicioPersonalizado == null || _fimPersonalizado == null) {
          return 'período personalizado';
        }
        return '${_dataCurta(_inicioPersonalizado!)} a ${_dataCurta(_fimPersonalizado!)}';
    }
  }

  List<OrcamentoRelatorio> get orcamentosFiltrados {
    final intervalo = _intervaloAtual;
    if (intervalo == null) return orcamentos.toList();
    final inicio = DateTime(intervalo.start.year, intervalo.start.month, intervalo.start.day);
    final fimExclusivo = DateTime(intervalo.end.year, intervalo.end.month, intervalo.end.day)
        .add(const Duration(days: 1));
    return orcamentos.where((item) {
      final data = item.orcamento.dataEvento;
      return !data.isBefore(inicio) && data.isBefore(fimExclusivo);
    }).toList();
  }

  ({DateTime start, DateTime end})? get _intervaloAtual {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    switch (periodoSelecionado.value) {
      case PeriodoRelatorio.todos:
        return null;
      case PeriodoRelatorio.mesAtual:
        return (start: DateTime(agora.year, agora.month, 1), end: DateTime(agora.year, agora.month + 1, 0));
      case PeriodoRelatorio.ultimos30Dias:
        return (start: hoje.subtract(const Duration(days: 29)), end: hoje);
      case PeriodoRelatorio.anoAtual:
        return (start: DateTime(agora.year, 1, 1), end: DateTime(agora.year, 12, 31));
      case PeriodoRelatorio.personalizado:
        if (_inicioPersonalizado == null || _fimPersonalizado == null) return null;
        return (start: _inicioPersonalizado!, end: _fimPersonalizado!);
    }
  }

  void definirPeriodo(PeriodoRelatorio periodo, {DateTime? inicio, DateTime? fim}) {
    if (periodo == PeriodoRelatorio.personalizado) {
      if (inicio == null || fim == null) return;
      _inicioPersonalizado = DateTime(inicio.year, inicio.month, inicio.day);
      _fimPersonalizado = DateTime(fim.year, fim.month, fim.day);
    }
    periodoSelecionado.value = periodo;
  }

  void limparPeriodo() {
    periodoSelecionado.value = PeriodoRelatorio.todos;
  }

  static String _dataCurta(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

  int get quantidadeTotal => orcamentosFiltrados.length;
  int get valorTotalCentavos =>
      orcamentosFiltrados.fold(0, (soma, item) => soma + item.totalCentavos);

  int get quantidadeAprovados => _contar({'aprovado'});
  int get quantidadeEnviados => _contar({'enviado'});
  int get quantidadePendentes => _contar({'pendente'});
  int get quantidadePerdidos => _contar({'perdido', 'recusado'});

  int get valorAprovadoCentavos => _somar({'aprovado'});
  int get valorEnviadoCentavos => _somar({'enviado'});
  int get valorPendenteCentavos => _somar({'pendente'});
  int get valorPerdidoCentavos => _somar({'perdido', 'recusado'});

  int get quantidadeConcluida => quantidadeAprovados + quantidadePerdidos;

  double get taxaConversao => quantidadeConcluida == 0
      ? 0
      : quantidadeAprovados / quantidadeConcluida;

  int _contar(Set<String> status) => orcamentosFiltrados
      .where((item) => status.contains(item.orcamento.status.toLowerCase()))
      .length;

  int _somar(Set<String> status) => orcamentosFiltrados
      .where((item) => status.contains(item.orcamento.status.toLowerCase()))
      .fold(0, (soma, item) => soma + item.totalCentavos);
}
