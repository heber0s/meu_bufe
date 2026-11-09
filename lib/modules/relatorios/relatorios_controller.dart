import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';

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

  int get quantidadeTotal => orcamentos.length;
  int get valorTotalCentavos =>
      orcamentos.fold(0, (soma, item) => soma + item.totalCentavos);

  int get quantidadeAprovados => _contar({'aprovado'});
  int get quantidadeEnviados => _contar({'enviado'});
  int get quantidadePendentes => _contar({'pendente'});
  int get quantidadePerdidos => _contar({'perdido', 'recusado'});

  int get valorAprovadoCentavos => _somar({'aprovado'});
  int get valorEnviadoCentavos => _somar({'enviado'});
  int get valorPendenteCentavos => _somar({'pendente'});
  int get valorPerdidoCentavos => _somar({'perdido', 'recusado'});

  int get quantidadeConcluida =>
      quantidadeAprovados + quantidadePerdidos;

  double get taxaConversao => quantidadeConcluida == 0
      ? 0
      : quantidadeAprovados / quantidadeConcluida;

  int _contar(Set<String> status) => orcamentos
      .where((item) => status.contains(item.orcamento.status.toLowerCase()))
      .length;

  int _somar(Set<String> status) => orcamentos
      .where((item) => status.contains(item.orcamento.status.toLowerCase()))
      .fold(0, (soma, item) => soma + item.totalCentavos);
}
