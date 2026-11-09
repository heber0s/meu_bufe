// modules/orcamentos/orcamentos_lista_controller.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';

/// Orçamento + cliente + total já calculado, pronto para a UI.
class OrcamentoResumo {
  OrcamentoResumo(this.orcamento, this.cliente, this.itens);

  final Orcamento orcamento;
  final Cliente cliente;
  final List<OrcamentoIten> itens;

  int get subtotalCentavos => itens.fold<int>(0, (soma, item) {
      final preco = item.precoCentavos;
      final total = switch (item.tipoCobranca) {
        'porConvidado' => preco * orcamento.convidados,
        'porUnidade' => preco * item.quantidade,
        _ => preco,
      };

      return soma + total;
    });

  int get totalCentavos =>
      math.max(0, subtotalCentavos - orcamento.descontoCentavos);
}

class OrcamentosListaController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final resumos = <OrcamentoResumo>[].obs;
  final carregando = true.obs;
  final filtro = 'todos'.obs; // todos | pendente | enviado | aprovado | perdido
  final busca = ''.obs;

  StreamSubscription<List<OrcamentoResumo>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _observarOrcamentos().listen((lista) {
      resumos.assignAll(lista);
      carregando.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel(); // evita vazamento quando o controller é descartado
    super.onClose();
  }

  Stream<List<OrcamentoResumo>> _observarOrcamentos() {
    final query = db.select(db.orcamentos).join([
      innerJoin(
          db.clientes, db.clientes.id.equalsExp(db.orcamentos.clienteId)),
      leftOuterJoin(db.orcamentoItens,
          db.orcamentoItens.orcamentoId.equalsExp(db.orcamentos.id)),
    ])
      ..orderBy([OrderingTerm.asc(db.orcamentos.dataEvento)]);

    return query.watch().map((rows) {
      // O join devolve uma linha por item; aqui agrupamos por orçamento.
      final grupos = <int, OrcamentoResumo>{};
      for (final row in rows) {
        final orc = row.readTable(db.orcamentos);
        final cli = row.readTable(db.clientes);
        final item = row.readTableOrNull(db.orcamentoItens);
        final resumo =
            grupos.putIfAbsent(orc.id, () => OrcamentoResumo(orc, cli, []));
        if (item != null) resumo.itens.add(item);
      }
      return grupos.values.toList();
    });
  }

  // ---- Derivados (lidos dentro de Obx, então reagem a qualquer mudança) ----

  List<OrcamentoResumo> get filtrados {
    final termo = busca.value.trim().toLowerCase();
    return resumos.where((r) {
      final status = r.orcamento.status.toLowerCase();
      final passaStatus = filtro.value == 'todos' ||
          status == filtro.value ||
          (filtro.value == 'perdido' && status == 'recusado');
      final passaBusca = termo.isEmpty ||
          r.orcamento.titulo.toLowerCase().contains(termo) ||
          r.cliente.nome.toLowerCase().contains(termo);
      return passaStatus && passaBusca;
    }).toList();
  }

  int get totalAprovadoCentavos => _somaPorStatus('aprovado');
  int get totalPendenteCentavos => _somaPorStatus('pendente');
  int get totalEnviadoCentavos => _somaPorStatus('enviado');
  int get totalPerdidoCentavos => _somaPorStatus('perdido') + _somaPorStatus('recusado');
  int get totalEmNegociacaoCentavos =>
      totalPendenteCentavos + totalEnviadoCentavos;

  int get quantidadeAprovados => _quantidadePorStatus('aprovado');
  int get quantidadePendentes => _quantidadePorStatus('pendente');
  int get quantidadeEnviados => _quantidadePorStatus('enviado');
  int get quantidadePerdidos =>
      _quantidadePorStatus('perdido') + _quantidadePorStatus('recusado');

  int get quantidadeNoFunil => quantidadeAprovados +
      quantidadePendentes + quantidadeEnviados + quantidadePerdidos;

  /// Percentual de aprovados entre todos os orçamentos do funil.
  double get participacaoAprovados => quantidadeNoFunil == 0
      ? 0.0
      : quantidadeAprovados / quantidadeNoFunil;

  int _quantidadePorStatus(String status) => resumos
      .where((r) => r.orcamento.status.toLowerCase() == status)
      .length;

  int _somaPorStatus(String status) => resumos
      .where((r) => r.orcamento.status == status)
      .fold(0, (s, r) => s + r.totalCentavos);

  void definirFiltro(String valor) => filtro.value = valor;
}