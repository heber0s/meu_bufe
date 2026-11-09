import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:meu_bufe/modules/orcamentos/orcamento_controller.dart'
    show ItemOrcamento;
import 'package:meu_bufe/modules/orcamentos/orcamento_totais.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/orcamento_pdf_service.dart';
import '../../core/services/notificacao_service.dart';
import '../../core/services/receita_orcamento_service.dart';
import '../../data/database/app_database.dart';
import 'widgets/orcamento_item_editor.dart';

class OrcamentoAcompanhamento {
  const OrcamentoAcompanhamento({
    required this.id,
    required this.contatoEm,
    required this.canal,
    required this.resumo,
    required this.proximoRetorno,
  });

  final int id;
  final DateTime contatoEm;
  final String canal;
  final String resumo;
  final DateTime? proximoRetorno;

  factory OrcamentoAcompanhamento.fromRow(QueryRow row) {
    final retornoMs = row.read<int?>('proximo_retorno');
    return OrcamentoAcompanhamento(
      id: row.read<int>('id'),
      contatoEm: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('contato_em'),
      ),
      canal: row.read<String>('canal'),
      resumo: row.read<String>('resumo'),
      proximoRetorno: retornoMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(retornoMs),
    );
  }
}

class OrcamentoHistorico {
  const OrcamentoHistorico({
    required this.id,
    required this.ocorridoEm,
    required this.tipo,
    required this.campo,
    required this.valorAnterior,
    required this.valorNovo,
    required this.autor,
  });

  final int id;
  final DateTime ocorridoEm;
  final String tipo;
  final String campo;
  final String? valorAnterior;
  final String? valorNovo;
  final String autor;

  factory OrcamentoHistorico.fromRow(QueryRow row) {
    return OrcamentoHistorico(
      id: row.read<int>('id'),
      ocorridoEm: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('ocorrido_em'),
      ),
      tipo: row.read<String>('tipo'),
      campo: row.read<String>('campo'),
      valorAnterior: row.read<String?>('valor_anterior'),
      valorNovo: row.read<String?>('valor_novo'),
      autor: row.read<String>('autor'),
    );
  }
}

class OrcamentoDetalheController extends GetxController {
  OrcamentoDetalheController({
    AppDatabase? database,
  }) : db = database ?? Get.find<AppDatabase>();

  final AppDatabase db;

  late final ReceitaOrcamentoService receitaOrcamentoService;

  final orcamento = Rxn<Orcamento>();
  final itens = <OrcamentoIten>[].obs;
  final receitas = <Receita>[].obs;
  final acompanhamentos = <OrcamentoAcompanhamento>[].obs;
  final historico = <OrcamentoHistorico>[].obs;
  final carregando = false.obs;
  final processando = false.obs;
  final salvando = false.obs;
  final erro = RxnString();
  final cliente = Rxn<Cliente>();

  static const duracaoPadraoEvento = Duration(hours: 5);

  StreamSubscription<List<OrcamentoIten>>? _itensSubscription;
  StreamSubscription<List<Receita>>? _receitasSubscription;

  int get orcamentoId {
    final argumento = Get.arguments;

    if (argumento is int) return argumento;
    if (argumento is String) return int.tryParse(argumento) ?? 0;

    final parametro = Get.parameters['id'];
    return int.tryParse(parametro ?? '') ?? 0;
  }

  int get convidados => orcamento.value?.convidados ?? 0;

  OrcamentoTotais get totais {
    final atual = orcamento.value;

    if (atual == null) {
      return const OrcamentoTotais(
        supermercadoCentavos: 0,
        combustivelETempoCentavos: 0,
        servicosCentavos: 0,
        descontoCentavos: 0,
        totalCentavos: 0,
      );
    }

    return OrcamentoTotais.calcular(
      orcamento: atual,
      itens: itens.toList(),
    );
  }

  int get subtotalCentavos => totais.subtotalCentavos;
  int get totalCentavos => totais.totalCentavos;
  String get totalFormatado => formatarCentavos(totalCentavos);

  String formatarCentavos(int centavos) {
    final valor = centavos / 100;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  bool get aprovado => orcamento.value?.status.toLowerCase() == 'aprovado';
  bool get perdido => orcamento.value?.status.toLowerCase() == 'perdido';
  bool get podeEditar => !aprovado && !perdido;

  bool _bloqueadoPorAprovacao() {
    if (podeEditar) return false;

    Get.snackbar(
      aprovado ? 'Orçamento confirmado' : 'Orçamento perdido',
      aprovado
          ? 'Reabra o orçamento para fazer alterações.'
          : 'Reabra para negociação antes de alterar os produtos.',
      snackPosition: SnackPosition.BOTTOM,
    );

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    receitaOrcamentoService = ReceitaOrcamentoService(db);
    carregarOrcamento();
    _observarReceitas();
  }

  @override
  void onClose() {
    _itensSubscription?.cancel();
    _receitasSubscription?.cancel();
    super.onClose();
  }

  Future<void> carregarOrcamento() async {
    if (orcamentoId <= 0) {
      erro.value = 'Identificador do orçamento inválido.';
      return;
    }

    carregando.value = true;
    erro.value = null;

    try {
      final resultado = await (db.select(db.orcamentos)
            ..where((tabela) => tabela.id.equals(orcamentoId)))
          .getSingleOrNull();

      if (resultado == null) {
        orcamento.value = null;
        cliente.value = null;
        itens.clear();
        erro.value = 'Orçamento não encontrado.';
        return;
      }

      orcamento.value = resultado;

      cliente.value = await (db.select(db.clientes)
            ..where((c) => c.id.equals(resultado.clienteId)))
          .getSingleOrNull();

      _observarItens();
      await carregarAcompanhamentos();
      await carregarHistorico();
    } catch (_) {
      erro.value = 'Não foi possível carregar o orçamento.';
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      carregando.value = false;
    }
  }

  Future<void> carregarAcompanhamentos() async {
    final linhas = await db.customSelect(
      '''
      SELECT id, contato_em, canal, resumo, proximo_retorno
      FROM orcamento_acompanhamentos
      WHERE orcamento_id = ?
      ORDER BY contato_em DESC, id DESC
      ''',
      variables: [Variable.withInt(orcamentoId)],
    ).get();
    acompanhamentos.assignAll(
      linhas.map(OrcamentoAcompanhamento.fromRow),
    );
  }

  Future<void> carregarHistorico() async {
    final linhas = await db.customSelect(
      '''
      SELECT id, ocorrido_em, tipo, campo, valor_anterior, valor_novo, autor
      FROM orcamento_historico
      WHERE orcamento_id = ?
      ORDER BY ocorrido_em DESC, id DESC
      ''',
      variables: [Variable.withInt(orcamentoId)],
    ).get();
    historico.assignAll(linhas.map(OrcamentoHistorico.fromRow));
  }

  Future<void> _registrarHistorico({
    required String tipo,
    required String campo,
    String? anterior,
    String? novo,
  }) async {
    await db.customStatement(
      '''
      INSERT INTO orcamento_historico
        (orcamento_id, ocorrido_em, tipo, campo, valor_anterior, valor_novo, autor)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        orcamentoId,
        DateTime.now().millisecondsSinceEpoch,
        tipo,
        campo,
        anterior,
        novo,
        'Usuário local',
      ],
    );
    await carregarHistorico();
  }

  String _resumoItem(ItemOrcamento item) {
    return '${item.nome} · qtd. ${item.quantidade} · '
        '${formatarCentavos(item.precoCentavos)} · ${item.tipoCobranca}';
  }

  String _resumoItemBanco(OrcamentoIten item) {
    return '${item.nome} · qtd. ${item.quantidade} · '
        '${formatarCentavos(item.precoCentavos)} · ${item.tipoCobranca}';
  }

  Future<String> _resumoItensBanco() async {
    final registros = await (db.select(db.orcamentoItens)
          ..where((item) => item.orcamentoId.equals(orcamentoId))
          ..orderBy([(item) => OrderingTerm.asc(item.id)]))
        .get();
    return registros.isEmpty
        ? 'Nenhum item'
        : registros.map(_resumoItemBanco).join('\n');
  }

  Future<void> registrarAcompanhamento({
    required String canal,
    required String resumo,
    required DateTime? proximoRetorno,
  }) async {
    final atual = orcamento.value;
    final clienteAtual = cliente.value;
    if (atual == null || clienteAtual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }
    if (aprovado) {
      Get.snackbar(
        'Orçamento aprovado',
        'Não é necessário agendar novos retornos para este orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (resumo.trim().isEmpty) {
      Get.snackbar(
        'Resumo obrigatório',
        'Descreva brevemente o resultado do contato.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (proximoRetorno != null && !proximoRetorno.isAfter(DateTime.now())) {
      Get.snackbar(
        'Data inválida',
        'Escolha uma data futura ou remova o lembrete.',
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
          atual.id,
          DateTime.now().millisecondsSinceEpoch,
          canal,
          resumo.trim(),
          proximoRetorno?.millisecondsSinceEpoch,
        ],
      );
      await carregarAcompanhamentos();

      if (Get.isRegistered<NotificacaoService>()) {
        final notificacoes = Get.find<NotificacaoService>();
        try {
          if (proximoRetorno == null) {
            await notificacoes.cancelarRetorno(atual.id);
          } else {
            await notificacoes.agendarRetorno(
              orcamentoId: atual.id,
              titulo: atual.titulo,
              cliente: clienteAtual.nome,
              resumo: resumo,
              quando: proximoRetorno,
            );
          }
        } catch (_) {
          Get.snackbar(
            'Contato registrado',
            'O registro foi salvo, mas não foi possível configurar a notificação.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      Get.snackbar(
        'Contato registrado',
        proximoRetorno == null
            ? 'O histórico foi atualizado sem novo lembrete.'
            : 'O retorno ficou agendado para '
                '${_formatarDataHora(proximoRetorno)}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar o contato no orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }

  void _observarItens() {
    _itensSubscription?.cancel();

    final consulta = db.select(db.orcamentoItens)
      ..where((item) => item.orcamentoId.equals(orcamentoId))
      ..orderBy([
        (item) => OrderingTerm(
              expression: item.id,
              mode: OrderingMode.asc,
            ),
      ]);

    _itensSubscription = consulta.watch().listen(
      itens.assignAll,
      onError: (Object _) {
        Get.snackbar(
          'Erro',
          'Não foi possível atualizar os produtos do orçamento.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _observarReceitas() {
    _receitasSubscription?.cancel();

    final consulta = db.select(db.receitas)
      ..orderBy([
        (receita) => OrderingTerm(
              expression: receita.nome,
              mode: OrderingMode.asc,
            ),
      ]);

    _receitasSubscription = consulta.watch().listen(
      receitas.assignAll,
      onError: (Object _) {
        Get.snackbar(
          'Erro',
          'Não foi possível carregar as receitas.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> salvarOrcamento() async {
    if (salvando.value || processando.value) return;

    if (orcamento.value == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    // As alterações de itens já são gravadas diretamente no banco.
    salvando.value = true;
    try {
      Get.back(closeOverlays: true);
    } finally {
      salvando.value = false;
    }
  }

  /// Abre o editor compartilhado usado também na criação do orçamento.
  Future<void> abrirItemManual() async {
    if (_bloqueadoPorAprovacao()) return;

    if (orcamento.value == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    final item = await Get.bottomSheet<ItemOrcamento>(
      const OrcamentoItemEditorSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (item == null) return;
    await _inserirItem(item);
  }

  /// Mantido como alias caso alguma parte da aplicação ainda use este nome.
  Future<void> abrirCadastroProdutoManual() => abrirItemManual();

  Future<void> _inserirItem(ItemOrcamento item) async {
    if (_bloqueadoPorAprovacao() || processando.value) return;

    processando.value = true;

    try {
      await db.into(db.orcamentoItens).insert(
            OrcamentoItensCompanion.insert(
              orcamentoId: orcamentoId,
              nome: item.nome,
              quantidade: Value(item.quantidade),
              precoCentavos: Value(item.precoCentavos),
              tipoCobranca: Value(item.tipoCobranca),
              categoria: Value(item.categoria),
              unidade: Value(item.unidade),
              quantidadeMilesimos: Value(item.quantidadeMilesimos),
              receitaId: Value(item.receitaId),
              receitaIngredienteId: Value(item.receitaIngredienteId),
              receitaNome: Value(item.receitaNome),
              servicoId: Value(item.servicoId),
            ),
          );

      await _registrarHistorico(
        tipo: 'Item adicionado',
        campo: 'Itens e valores',
        novo: _resumoItem(item),
      );

      Get.snackbar(
        'Item adicionado',
        'O item foi incluído no orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível adicionar o item ao orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> abrirSelecaoServico() async {
    if (_bloqueadoPorAprovacao()) return;

    if (orcamento.value == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    try {
      final servicosAtivos = await (db.select(db.servicos)
            ..where((servico) => servico.ativo.equals(true))
            ..orderBy([
              (servico) => OrderingTerm(
                    expression: servico.nome,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

      if (servicosAtivos.isEmpty) {
        Get.snackbar(
          'Nenhum serviço disponível',
          'Cadastre ou ative um serviço no catálogo para adicioná-lo.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final servico = await Get.bottomSheet<Servico>(
        OrcamentoServicoSelectorSheet(servicos: servicosAtivos),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );

      if (servico == null) return;

      final item = await Get.bottomSheet<ItemOrcamento>(
        OrcamentoItemEditorSheet(servico: servico),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );

      if (item == null) return;
      await _inserirItem(item);
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os serviços do catálogo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> abrirSelecaoReceita() async {
    if (_bloqueadoPorAprovacao()) return;

    final atual = orcamento.value;
    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    if (atual.convidados <= 0) {
      Get.snackbar(
        'Convidados não informados',
        'Informe a quantidade de convidados antes de adicionar uma receita.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (receitas.isEmpty) {
      Get.snackbar(
        'Nenhuma receita cadastrada',
        'Cadastre pelo menos uma receita antes de adicioná-la ao orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final receita = await Get.bottomSheet<Receita>(
      OrcamentoReceitaSelectorSheet(
        receitas: receitas.toList(),
        subtitulo:
            'Os ingredientes serão calculados para ${atual.convidados} convidados.',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (receita == null) return;
    await adicionarReceita(receita.id);
  }

  Future<void> adicionarReceita(int receitaId) async {
    if (_bloqueadoPorAprovacao() || processando.value) return;

    final atual = orcamento.value;

    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    if (atual.convidados <= 0) {
      Get.snackbar(
        'Convidados não informados',
        'Informe a quantidade de convidados antes de adicionar uma receita.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    processando.value = true;

    try {
      final itensAntes = await _resumoItensBanco();
      await receitaOrcamentoService.adicionarReceitaAoOrcamento(
        orcamentoId: atual.id,
        convidados: atual.convidados,
        receitaId: receitaId,
      );

      final itensDepois = await _resumoItensBanco();
      await _registrarHistorico(
        tipo: 'Receita adicionada',
        campo: 'Itens e valores',
        anterior: itensAntes,
        novo: itensDepois,
      );

      Get.snackbar(
        'Receita adicionada',
        'Os ingredientes foram calculados para '
            '${atual.convidados} convidados.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro ao adicionar receita',
        _mensagemErro(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> editarItem(OrcamentoIten item) async {
    if (_bloqueadoPorAprovacao()) return;

    final itemEditor = ItemOrcamento(
      nome: item.nome,
      precoCentavos: item.precoCentavos,
      quantidade: item.quantidade,
      tipoCobranca: item.tipoCobranca,
      categoria: item.categoria,
      receitaId: item.receitaId,
      receitaIngredienteId: item.receitaIngredienteId,
      receitaNome: item.receitaNome,
      unidade: item.unidade,
      quantidadeMilesimos: item.quantidadeMilesimos,
      servicoId: item.servicoId,
    );

    final resultado = await Get.bottomSheet<ItemOrcamento>(
      OrcamentoItemEditorSheet(item: itemEditor),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (resultado == null) return;
    await atualizarItem(itemId: item.id, item: resultado);
  }

  Future<void> atualizarItem({
    required int itemId,
    required ItemOrcamento item,
  }) async {
    if (_bloqueadoPorAprovacao() || processando.value) return;

    processando.value = true;

    try {
      final anterior = await (db.select(db.orcamentoItens)
            ..where((registro) => registro.id.equals(itemId)))
          .getSingleOrNull();
      await (db.update(db.orcamentoItens)
            ..where((registro) => registro.id.equals(itemId)))
          .write(
        OrcamentoItensCompanion(
          nome: Value(item.nome),
          quantidade: Value(item.quantidade),
          precoCentavos: Value(item.precoCentavos),
          tipoCobranca: Value(item.tipoCobranca),
          categoria: Value(item.categoria),
          unidade: Value(item.unidade),
          quantidadeMilesimos: Value(item.quantidadeMilesimos),
          receitaId: Value(item.receitaId),
          receitaIngredienteId: Value(item.receitaIngredienteId),
          receitaNome: Value(item.receitaNome),
          servicoId: Value(item.servicoId),
        ),
      );

      if (anterior != null) {
        await _registrarHistorico(
          tipo: 'Item alterado',
          campo: 'Itens e valores',
          anterior: _resumoItemBanco(anterior),
          novo: _resumoItem(item),
        );
      }

      Get.snackbar(
        'Item atualizado',
        'As alterações foram gravadas no orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o item.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  /// Compatibilidade com chamadas antigas da tela.
  Future<void> atualizarItemManualmente({
    required int itemId,
    required dynamic formulario,
  }) async {
    if (formulario is! ItemOrcamento) return;
    await atualizarItem(itemId: itemId, item: formulario);
  }

  Future<void> excluirItem(int itemId) async {
    if (_bloqueadoPorAprovacao() || processando.value) return;

    processando.value = true;

    try {
      final anterior = await (db.select(db.orcamentoItens)
            ..where((item) => item.id.equals(itemId)))
          .getSingleOrNull();
      await (db.delete(db.orcamentoItens)
            ..where((item) => item.id.equals(itemId)))
          .go();

      if (anterior != null) {
        await _registrarHistorico(
          tipo: 'Item removido',
          campo: 'Itens e valores',
          anterior: _resumoItemBanco(anterior),
          novo: null,
        );
      }

      Get.snackbar(
        'Produto removido',
        'O produto foi removido do orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível remover o produto.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> removerReceita(int receitaId) async {
    if (_bloqueadoPorAprovacao() || processando.value) return;

    processando.value = true;

    try {
      final itensAntes = await _resumoItensBanco();
      await receitaOrcamentoService.removerReceitaDoOrcamento(
        orcamentoId: orcamentoId,
        receitaId: receitaId,
      );

      final itensDepois = await _resumoItensBanco();
      await _registrarHistorico(
        tipo: 'Receita removida',
        campo: 'Itens e valores',
        anterior: itensAntes,
        novo: itensDepois,
      );

      Get.snackbar(
        'Receita removida',
        'Os ingredientes dessa receita foram removidos do orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível remover a receita.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> gerarEEnviarPdf() async {
    if (processando.value) return;

    final atual = orcamento.value;

    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    processando.value = true;

    try {
      final arquivo = await OrcamentoPdfService.gerar(
        orcamento: atual,
        cliente: cliente.value,
        itens: itens.toList(),
      );

      await SharePlus.instance.share(
        ShareParams(
          text: 'Segue o orçamento "${atual.titulo}".',
          subject: 'Orçamento - ${atual.titulo}',
          files: [
            XFile(
              arquivo.path,
              mimeType: 'application/pdf',
            ),
          ],
        ),
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível gerar ou compartilhar o PDF.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> confirmarOrcamento() async {
    if (processando.value) return;

    final atual = orcamento.value;

    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    if (atual.status.toLowerCase() == 'aprovado') {
      Get.snackbar(
        'Orçamento já confirmado',
        'Este orçamento já está aprovado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar orçamento?'),
        content: Text(
          'O orçamento "${atual.titulo}" será marcado como aprovado '
          'e o evento será incluído na agenda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    processando.value = true;

    try {
      await db.transaction(() async {
        await (db.update(db.orcamentos)
              ..where((orcamento) => orcamento.id.equals(atual.id)))
            .write(
          const OrcamentosCompanion(
            status: Value('aprovado'),
          ),
        );
        await db.customStatement(
          '''
          INSERT INTO orcamento_historico
            (orcamento_id, ocorrido_em, tipo, campo, valor_anterior,
             valor_novo, autor)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            atual.id,
            DateTime.now().millisecondsSinceEpoch,
            'Orçamento aprovado',
            'Status',
            atual.status,
            'aprovado',
            'Usuário local',
          ],
        );

        final eventoExistente = await (db.select(db.eventos)
              ..where((evento) => evento.orcamentoId.equals(atual.id))
              ..limit(1))
            .getSingleOrNull();

        if (eventoExistente == null) {
          await db.into(db.eventos).insert(
                EventosCompanion.insert(
                  orcamentoId: Value(atual.id),
                  titulo: atual.titulo,
                  local: Value(atual.local),
                  inicio: atual.dataEvento,
                  fim: atual.dataEvento.add(duracaoPadraoEvento),
                ),
              );
        } else {
          await (db.update(db.eventos)
                ..where((evento) => evento.id.equals(eventoExistente.id)))
              .write(
            EventosCompanion(
              titulo: Value(atual.titulo),
              local: Value(atual.local),
              inicio: Value(atual.dataEvento),
              fim: Value(atual.dataEvento.add(duracaoPadraoEvento)),
            ),
          );
        }
      });

      await carregarOrcamento();

      if (Get.isRegistered<NotificacaoService>()) {
        await Get.find<NotificacaoService>().cancelarRetorno(atual.id);
      }

      Get.snackbar(
        'Orçamento confirmado',
        'O orçamento foi aprovado e o evento foi incluído na agenda.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível confirmar o orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> reabrirOrcamento() async {
    if (processando.value) return;

    final atual = orcamento.value;

    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    if (atual.status.toLowerCase() != 'aprovado') return;

    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reabrir orçamento?'),
        content: Text(
          'O orçamento "${atual.titulo}" voltará para pendente e o evento '
          'será removido da agenda até que você confirme novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reabrir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    processando.value = true;

    try {
      await db.transaction(() async {
        await (db.update(db.orcamentos)
              ..where((orcamento) => orcamento.id.equals(atual.id)))
            .write(
          const OrcamentosCompanion(
            status: Value('pendente'),
          ),
        );
        await db.customStatement(
          '''
          INSERT INTO orcamento_historico
            (orcamento_id, ocorrido_em, tipo, campo, valor_anterior,
             valor_novo, autor)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            atual.id,
            DateTime.now().millisecondsSinceEpoch,
            'Orçamento reaberto',
            'Status',
            atual.status,
            'pendente',
            'Usuário local',
          ],
        );

        await (db.delete(db.eventos)
              ..where((evento) => evento.orcamentoId.equals(atual.id)))
            .go();
      });

      await carregarOrcamento();

      Get.snackbar(
        'Orçamento reaberto',
        'Agora você pode editar os itens. Confirme novamente ao terminar.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível reabrir o orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> marcarComoEnviado() => _alterarStatusComercial(
        novoStatus: 'enviado',
        tituloDialogo: 'Marcar como enviado?',
        descricao: 'Registre que o orçamento foi enviado ao cliente.',
        rotuloAcao: 'Marcar enviado',
        tipoHistorico: 'Orçamento enviado',
        mensagemSucesso: 'O orçamento foi marcado como enviado.',
      );

  Future<void> marcarComoPerdido() => _alterarStatusComercial(
        novoStatus: 'perdido',
        tituloDialogo: 'Marcar como perdido?',
        descricao: 'O orçamento sairá das negociações ativas.',
        rotuloAcao: 'Marcar perdido',
        tipoHistorico: 'Orçamento perdido',
        mensagemSucesso: 'O orçamento foi marcado como perdido.',
      );

  Future<void> reabrirParaNegociacao() => _alterarStatusComercial(
        novoStatus: 'pendente',
        tituloDialogo: 'Reabrir para negociação?',
        descricao: 'O orçamento voltará para as negociações ativas.',
        rotuloAcao: 'Reabrir',
        tipoHistorico: 'Orçamento reaberto para negociação',
        mensagemSucesso: 'O orçamento voltou para as negociações ativas.',
      );

  Future<void> _alterarStatusComercial({
    required String novoStatus,
    required String tituloDialogo,
    required String descricao,
    required String rotuloAcao,
    required String tipoHistorico,
    required String mensagemSucesso,
  }) async {
    if (processando.value) return;

    final atual = orcamento.value;
    if (atual == null) {
      _mostrarMensagemOrcamentoIndisponivel();
      return;
    }

    final statusAtual = atual.status.toLowerCase();
    if (statusAtual == 'aprovado' || statusAtual == novoStatus) return;
    if (novoStatus == 'enviado' && statusAtual != 'pendente') return;
    if (novoStatus == 'perdido' &&
        statusAtual != 'pendente' &&
        statusAtual != 'enviado') {
      return;
    }
    if (novoStatus == 'pendente' && statusAtual != 'perdido') return;

    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: Text(tituloDialogo),
        content: Text(descricao),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(rotuloAcao),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    processando.value = true;
    try {
      await db.transaction(() async {
        await (db.update(db.orcamentos)
              ..where((orcamento) => orcamento.id.equals(atual.id)))
            .write(OrcamentosCompanion(status: Value(novoStatus)));

        await db.customStatement(
          '''
          INSERT INTO orcamento_historico
            (orcamento_id, ocorrido_em, tipo, campo, valor_anterior,
             valor_novo, autor)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            atual.id,
            DateTime.now().millisecondsSinceEpoch,
            tipoHistorico,
            'Status',
            atual.status,
            novoStatus,
            'Usuário local',
          ],
        );

        if (novoStatus == 'perdido') {
          await (db.delete(db.eventos)
                ..where((evento) => evento.orcamentoId.equals(atual.id)))
              .go();
        }
      });

      await carregarOrcamento();
      if (novoStatus == 'perdido' &&
          Get.isRegistered<NotificacaoService>()) {
        try {
          await Get.find<NotificacaoService>().cancelarRetorno(atual.id);
        } catch (_) {
          Get.snackbar(
            'Status atualizado',
            'O orçamento foi marcado como perdido, mas o lembrete local não foi cancelado.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      Get.snackbar(
        'Status atualizado',
        mensagemSucesso,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o status do orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  String _mensagemErro(Object erro) {
    final mensagem = erro.toString();

    if (mensagem.startsWith('Exception:')) {
      return mensagem.replaceFirst('Exception:', '').trim();
    }

    return mensagem;
  }

  void _mostrarMensagemOrcamentoIndisponivel() {
    Get.snackbar(
      'Orçamento indisponível',
      'Salve ou carregue o orçamento antes de adicionar produtos.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}