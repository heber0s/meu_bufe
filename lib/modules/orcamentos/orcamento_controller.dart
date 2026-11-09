import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../core/utils/formatters.dart';
import '../../core/utils/moeda_input_formatter.dart';
import '../../data/database/app_database.dart';

class ItemOrcamento {
  const ItemOrcamento({
    required this.nome,
    required this.precoCentavos,
    this.quantidade = 1,
    this.tipoCobranca = cobrancaGeral,
    this.categoria = categoriaServico,
    this.receitaId,
    this.receitaIngredienteId,
    this.receitaNome,
    this.unidade,
    this.quantidadeMilesimos = 1000,
    this.servicoId,
  });

  static const String cobrancaPorConvidado = 'porConvidado';
  static const String cobrancaPorUnidade = 'porUnidade';
  static const String cobrancaGeral = 'geral';

  static const String categoriaIngrediente = 'ingrediente';
  static const String categoriaServico = 'servico';

  final String nome;
  final int precoCentavos;
  final int quantidade;
  final String tipoCobranca;
  final String categoria;
  final int? receitaId;
  final int? receitaIngredienteId;
  final String? receitaNome;
  final String? unidade;
  final int quantidadeMilesimos;
  final int? servicoId;

  int totalCentavos(int convidados) {
    switch (tipoCobranca) {
      case cobrancaPorConvidado:
        return precoCentavos * convidados;
      case cobrancaPorUnidade:
        return precoCentavos * quantidade;
      case cobrancaGeral:
      default:
        return precoCentavos;
    }
  }
}

class OrcamentoTotais {
  const OrcamentoTotais({
    required this.supermercadoCentavos,
    required this.combustivelETempoCentavos,
    required this.servicosCentavos,
    required this.descontoCentavos,
    required this.totalCentavos,
  });

  final int supermercadoCentavos;
  final int combustivelETempoCentavos;
  final int servicosCentavos;
  final int descontoCentavos;
  final int totalCentavos;

  int get subtotalCentavos =>
      supermercadoCentavos +
      combustivelETempoCentavos +
      servicosCentavos;
}

class OrcamentoController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  /// Nulo para um orçamento novo; preenchido ao editar.
  int? orcamentoId;

  bool get editando => orcamentoId != null;

  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final obsCtrl = TextEditingController();
  final convidadosCtrl = TextEditingController();
  final descontoCtrl = TextEditingController();

  final cliente = Rxn<Cliente>();
  final dataEvento = Rxn<DateTime>();
  final convidados = 0.obs;
  final descontoCentavos = 0.obs;
  final itens = <ItemOrcamento>[].obs;
  final carregando = false.obs;
  final salvando = false.obs;
  final aprovado = false.obs;

  /// A decisão de compra é do orçamento, não de cada item.
  final ingredientesCompradosPeloBufe = true.obs;

  String _status = 'pendente';

  OrcamentoTotais get totais {
    var supermercado = 0;
    var servicos = 0;

    for (final item in itens) {
      final totalItem = item.totalCentavos(convidados.value);

      if (item.categoria == ItemOrcamento.categoriaIngrediente) {
        supermercado += totalItem;
      } else {
        servicos += totalItem;
      }
    }

    final supermercadoCobrado =
        ingredientesCompradosPeloBufe.value ? supermercado : 0;

    final adicional = ingredientesCompradosPeloBufe.value
        ? _vintePorCento(supermercado)
        : 0;

    final subtotal =
        supermercadoCobrado + adicional + servicos;
    final desconto = descontoCentavos.value;

    return OrcamentoTotais(
      supermercadoCentavos: supermercadoCobrado,
      combustivelETempoCentavos: adicional,
      servicosCentavos: servicos,
      descontoCentavos: desconto,
      totalCentavos: (subtotal - desconto).clamp(0, 0x7FFFFFFFFFFFFFFF),
    );
  }

  int get totalIngredientesCentavos =>
      totais.supermercadoCentavos;

  int get combustivelETempoCentavos =>
      totais.combustivelETempoCentavos;

  int get totalServicosCentavos =>
      totais.servicosCentavos;

  int get subtotalCentavos => totais.subtotalCentavos;

  int get totalCentavos => totais.totalCentavos;

  static int _vintePorCento(int valorCentavos) {
    if (valorCentavos <= 0) return 0;
    return (valorCentavos * 20 + 50) ~/ 100;
  }

  @override
  void onInit() {
    super.onInit();

    final argumento = Get.arguments;

    if (argumento is int && argumento > 0) {
      orcamentoId = argumento;
      _carregar(argumento);
    } else if (argumento is String) {
      final id = int.tryParse(argumento);
      if (id != null && id > 0) {
        orcamentoId = id;
        _carregar(id);
      }
    }
  }

  @override
  void onClose() {
    tituloCtrl.dispose();
    localCtrl.dispose();
    obsCtrl.dispose();
    convidadosCtrl.dispose();
    descontoCtrl.dispose();
    super.onClose();
  }

  void definirConvidados(String texto) {
    convidados.value = int.tryParse(texto.trim()) ?? 0;
  }

  void definirDesconto(String texto) {
    descontoCentavos.value = centavosDoTexto(texto);
  }

  void definirQuemCompraIngredientes(bool compraBufe) {
    ingredientesCompradosPeloBufe.value = compraBufe;
  }

  void selecionarCliente(Cliente novoCliente) {
    cliente.value = novoCliente;
  }

  void definirData(DateTime data) {
    dataEvento.value = data;
  }

  void adicionarItem(ItemOrcamento item) {
    itens.add(item);
  }

  void substituirItem(int index, ItemOrcamento item) {
    if (index < 0 || index >= itens.length) return;
    itens[index] = item;
  }

  void removerItem(int index) {
    if (index < 0 || index >= itens.length) return;
    itens.removeAt(index);
  }

  Future<List<Receita>> carregarReceitas() {
    return (db.select(db.receitas)
          ..orderBy([
            (receita) => OrderingTerm(
                  expression: receita.nome,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<void> adicionarReceitaAoFormulario(Receita receita) async {
    final quantidadeConvidados = convidados.value;

    if (quantidadeConvidados <= 0) {
      throw Exception(
        'Informe o número de convidados antes de adicionar uma receita.',
      );
    }

    if (receita.rendimentoPessoas <= 0) {
      throw Exception(
        'O rendimento da receita precisa ser maior que zero.',
      );
    }

    final ingredientes = await (db.select(db.receitaIngredientes)
          ..where((ingrediente) => ingrediente.receitaId.equals(receita.id))
          ..orderBy([
            (ingrediente) => OrderingTerm(
                  expression: ingrediente.id,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();

    if (ingredientes.isEmpty) {
      throw Exception('A receita selecionada não possui ingredientes.');
    }

    final novosItens = ingredientes.map((ingrediente) {
      final quantidadeCalculada =
          ((ingrediente.quantidadeMilesimos * quantidadeConvidados) /
                  receita.rendimentoPessoas)
              .round();

      final precoCalculado =
          ((ingrediente.precoCentavos ?? 0) *
                  quantidadeConvidados /
                  receita.rendimentoPessoas)
              .round();

      return ItemOrcamento(
        nome: ingrediente.produto,
        precoCentavos: precoCalculado,
        tipoCobranca: ItemOrcamento.cobrancaGeral,
        categoria: ItemOrcamento.categoriaIngrediente,
        receitaId: receita.id,
        receitaIngredienteId: ingrediente.id,
        receitaNome: receita.nome,
        unidade: ingrediente.unidade,
        quantidadeMilesimos: quantidadeCalculada,
      );
    }).toList();

    itens.addAll(novosItens);
  }

  Future<List<Servico>> carregarServicosAtivos() async {
    return (db.select(db.servicos)
          ..where((servico) => servico.ativo.equals(true))
          ..orderBy([
            (servico) => OrderingTerm(
                  expression: servico.nome,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<void> _carregar(int id) async {
    carregando.value = true;

    try {
      final orcamento = await (db.select(db.orcamentos)
            ..where((tabela) => tabela.id.equals(id)))
          .getSingleOrNull();

      if (orcamento == null) {
        Get.snackbar(
          'Orçamento não encontrado',
          'Não foi possível carregar este orçamento.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final clienteEncontrado = await (db.select(db.clientes)
            ..where((tabela) => tabela.id.equals(orcamento.clienteId)))
          .getSingleOrNull();

      final linhas = await (db.select(db.orcamentoItens)
            ..where((item) => item.orcamentoId.equals(id))
            ..orderBy([
              (item) => OrderingTerm(
                    expression: item.id,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

      _status = orcamento.status;
      aprovado.value = orcamento.status.toLowerCase() == 'aprovado';
      cliente.value = clienteEncontrado;
      dataEvento.value = orcamento.dataEvento;
      tituloCtrl.text = orcamento.titulo;
      localCtrl.text = orcamento.local ?? '';
      obsCtrl.text = orcamento.observacoes ?? '';
      convidadosCtrl.text = '${orcamento.convidados}';
      convidados.value = orcamento.convidados;
      ingredientesCompradosPeloBufe.value =
          orcamento.ingredientesCompradosPeloBufe;

      descontoCentavos.value = orcamento.descontoCentavos;
      descontoCtrl.text = orcamento.descontoCentavos > 0
          ? formatarMoeda(orcamento.descontoCentavos)
          : '';

      itens.assignAll(
        linhas.map(
          (item) => ItemOrcamento(
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
          ),
        ),
      );
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o orçamento: $erro',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      carregando.value = false;
    }
  }

  Future<void> salvar() async {
    if (salvando.value) return;

    if (aprovado.value) {
      Get.snackbar(
        'Orçamento confirmado',
        'Reabra o orçamento na tela de detalhes para fazer alterações.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final titulo = tituloCtrl.text.trim();
    final mensagemErro = titulo.isEmpty
        ? 'Dê um nome ao evento.'
        : cliente.value == null
            ? 'Selecione o cliente.'
            : dataEvento.value == null
                ? 'Escolha a data do evento.'
                : itens.isEmpty
                    ? 'Adicione ao menos um item ao orçamento.'
                    : null;

    if (mensagemErro != null) {
      Get.snackbar(
        'Quase lá',
        mensagemErro,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    salvando.value = true;

    try {
      final local = localCtrl.text.trim();
      final observacoes = obsCtrl.text.trim();
      final mudancas = <_MudancaOrcamento>[];
      final tipoHistorico = editando ? 'Orçamento atualizado' : 'Orçamento criado';

      if (editando) {
        final anterior = await (db.select(db.orcamentos)
              ..where((registro) => registro.id.equals(orcamentoId!)))
            .getSingleOrNull();
        if (anterior == null) {
          throw Exception('O orçamento não foi encontrado para atualização.');
        }
        final clienteAnterior = await (db.select(db.clientes)
              ..where((registro) => registro.id.equals(anterior.clienteId)))
            .getSingleOrNull();
        final itensAnteriores = await (db.select(db.orcamentoItens)
              ..where((registro) => registro.orcamentoId.equals(orcamentoId!))
              ..orderBy([(registro) => OrderingTerm.asc(registro.id)]))
            .get();

        _comparar(mudancas, 'Cliente', clienteAnterior?.nome,
            cliente.value!.nome);
        _comparar(mudancas, 'Nome do evento', anterior.titulo, titulo);
        _comparar(mudancas, 'Data e horário', _dataHistorico(anterior.dataEvento),
            _dataHistorico(dataEvento.value!));
        _comparar(mudancas, 'Local', _textoHistorico(anterior.local),
            _textoHistorico(local.isEmpty ? null : local));
        _comparar(mudancas, 'Convidados', '${anterior.convidados}',
            '${convidados.value}');
        _comparar(mudancas, 'Desconto', formatarMoeda(anterior.descontoCentavos),
            formatarMoeda(descontoCentavos.value));
        _comparar(
          mudancas,
          'Compra dos ingredientes',
          anterior.ingredientesCompradosPeloBufe ? 'Bufê' : 'Cliente',
          ingredientesCompradosPeloBufe.value ? 'Bufê' : 'Cliente',
        );
        _comparar(mudancas, 'Observações', _textoHistorico(anterior.observacoes),
            _textoHistorico(observacoes.isEmpty ? null : observacoes));

        final itensAntes = _resumoItensAntigos(itensAnteriores);
        final itensDepois = _resumoItensNovos(itens);
        _comparar(mudancas, 'Itens e valores', itensAntes, itensDepois);

        final totalAntes = _totalHistorico(anterior, itensAnteriores);
        _comparar(mudancas, 'Total do orçamento', formatarMoeda(totalAntes),
            formatarMoeda(totalCentavos));
      } else {
        mudancas.add(
          _MudancaOrcamento(
            campo: 'Orçamento',
            anterior: null,
            novo: '$titulo · Total: ${formatarMoeda(totalCentavos)}',
          ),
        );
      }

      await db.transaction(() async {
        late final int idSalvo;

        if (editando) {
          idSalvo = orcamentoId!;
          await (db.update(db.orcamentos)
                ..where((orcamento) => orcamento.id.equals(idSalvo)))
              .write(
            OrcamentosCompanion(
              clienteId: Value(cliente.value!.id),
              titulo: Value(titulo),
              dataEvento: Value(dataEvento.value!),
              local: Value(local.isEmpty ? null : local),
              convidados: Value(convidados.value),
              descontoCentavos: Value(descontoCentavos.value),
              ingredientesCompradosPeloBufe:
                  Value(ingredientesCompradosPeloBufe.value),
              observacoes: Value(observacoes.isEmpty ? null : observacoes),
            ),
          );
          await (db.delete(db.orcamentoItens)
                ..where((item) => item.orcamentoId.equals(idSalvo)))
              .go();
        } else {
          idSalvo = await db.into(db.orcamentos).insert(
                OrcamentosCompanion.insert(
                  clienteId: cliente.value!.id,
                  titulo: titulo,
                  dataEvento: dataEvento.value!,
                  local: Value(local.isEmpty ? null : local),
                  convidados: Value(convidados.value),
                  descontoCentavos: Value(descontoCentavos.value),
                  ingredientesCompradosPeloBufe:
                      Value(ingredientesCompradosPeloBufe.value),
                  observacoes: Value(observacoes.isEmpty ? null : observacoes),
                  status: Value(_status),
                ),
              );
        }

        for (final item in itens) {
          await db.into(db.orcamentoItens).insert(
                OrcamentoItensCompanion.insert(
                  orcamentoId: idSalvo,
                  nome: item.nome,
                  precoCentavos: Value(item.precoCentavos),
                  quantidade: Value(item.quantidade),
                  tipoCobranca: Value(item.tipoCobranca),
                  categoria: Value(item.categoria),
                  receitaId: Value(item.receitaId),
                  receitaIngredienteId: Value(item.receitaIngredienteId),
                  receitaNome: Value(item.receitaNome),
                  unidade: Value(item.unidade),
                  quantidadeMilesimos: Value(item.quantidadeMilesimos),
                  servicoId: Value(item.servicoId),
                ),
              );
        }

        final ocorridoEm = DateTime.now().millisecondsSinceEpoch;
        for (final mudanca in mudancas) {
          await db.customStatement(
            '''
            INSERT INTO orcamento_historico
              (orcamento_id, ocorrido_em, tipo, campo, valor_anterior,
               valor_novo, autor)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              idSalvo,
              ocorridoEm,
              tipoHistorico,
              mudanca.campo,
              mudanca.anterior,
              mudanca.novo,
              'Usuário local',
            ],
          );
        }
      });

      Get.back(result: true);
      Get.snackbar(
        'Pronto',
        editando ? 'Orçamento atualizado.' : 'Orçamento criado.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (erro) {
      Get.snackbar(
        'Não foi possível salvar',
        '$erro',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      salvando.value = false;
    }
  }

  void _comparar(
    List<_MudancaOrcamento> destino,
    String campo,
    String? anterior,
    String? novo,
  ) {
    if (anterior == novo) return;
    destino.add(
      _MudancaOrcamento(campo: campo, anterior: anterior, novo: novo),
    );
  }

  String _textoHistorico(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? '—' : texto;
  }

  String _dataHistorico(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }

  String _resumoItensAntigos(List<OrcamentoIten> lista) {
    if (lista.isEmpty) return 'Nenhum item';
    return lista.map((item) {
      final categoria = item.categoria == ItemOrcamento.categoriaIngrediente
          ? 'Ingrediente'
          : 'Serviço';
      return '${item.nome} · $categoria · qtd. ${item.quantidade} · '
          '${formatarMoeda(item.precoCentavos)} · ${item.tipoCobranca}';
    }).join('\n');
  }

  String _resumoItensNovos(List<ItemOrcamento> lista) {
    if (lista.isEmpty) return 'Nenhum item';
    return lista.map((item) {
      final categoria = item.categoria == ItemOrcamento.categoriaIngrediente
          ? 'Ingrediente'
          : 'Serviço';
      return '${item.nome} · $categoria · qtd. ${item.quantidade} · '
          '${formatarMoeda(item.precoCentavos)} · ${item.tipoCobranca}';
    }).join('\n');
  }

  int _totalHistorico(Orcamento orcamento, List<OrcamentoIten> lista) {
    var ingredientes = 0;
    var servicos = 0;
    for (final item in lista) {
      final totalItem = switch (item.tipoCobranca) {
        ItemOrcamento.cobrancaPorConvidado =>
          item.precoCentavos * orcamento.convidados,
        ItemOrcamento.cobrancaPorUnidade => item.precoCentavos * item.quantidade,
        _ => item.precoCentavos,
      };
      if (item.categoria == ItemOrcamento.categoriaIngrediente) {
        ingredientes += totalItem;
      } else {
        servicos += totalItem;
      }
    }
    final baseIngredientes = orcamento.ingredientesCompradosPeloBufe
        ? ingredientes
        : 0;
    final adicional = orcamento.ingredientesCompradosPeloBufe
        ? _vintePorCento(ingredientes)
        : 0;
    return (baseIngredientes + adicional + servicos - orcamento.descontoCentavos)
        .clamp(0, 0x7FFFFFFFFFFFFFFF);
  }
}

class _MudancaOrcamento {
  const _MudancaOrcamento({
    required this.campo,
    required this.anterior,
    required this.novo,
  });

  final String campo;
  final String? anterior;
  final String? novo;
}
