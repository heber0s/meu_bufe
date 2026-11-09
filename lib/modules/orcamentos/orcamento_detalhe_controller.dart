import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:meu_bufe/modules/orcamentos/orcamento_controller.dart'
    show ItemOrcamento;
import 'package:meu_bufe/modules/orcamentos/orcamento_totais.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/orcamento_pdf_service.dart';
import '../../core/services/receita_orcamento_service.dart';
import '../../data/database/app_database.dart';
import 'widgets/orcamento_item_editor.dart';

class OrcamentoDetalheController extends GetxController {
  OrcamentoDetalheController({
    AppDatabase? database,
  }) : db = database ?? Get.find<AppDatabase>();

  final AppDatabase db;

  late final ReceitaOrcamentoService receitaOrcamentoService;

  final orcamento = Rxn<Orcamento>();
  final itens = <OrcamentoIten>[].obs;
  final receitas = <Receita>[].obs;
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

  bool _bloqueadoPorAprovacao() {
    if (!aprovado) return false;

    Get.snackbar(
      'Orçamento confirmado',
      'Reabra o orçamento para fazer alterações.',
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
      await receitaOrcamentoService.adicionarReceitaAoOrcamento(
        orcamentoId: atual.id,
        convidados: atual.convidados,
        receitaId: receitaId,
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
      await (db.delete(db.orcamentoItens)
            ..where((item) => item.id.equals(itemId)))
          .go();

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
      await receitaOrcamentoService.removerReceitaDoOrcamento(
        orcamentoId: orcamentoId,
        receitaId: receitaId,
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