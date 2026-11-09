import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/moeda_input_formatter.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/database/app_database.dart';
import '../clientes/clientes_controller.dart';
import 'orcamento_controller.dart';

InputDecoration _decoracao(String rotulo, IconData icone) => InputDecoration(
      labelText: rotulo,
      prefixIcon: Icon(
        icone,
        color: AppColors.roseGold,
        size: 20,
      ),
      filled: true,
      fillColor: AppColors.fundo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.ouro,
          width: 1.2,
        ),
      ),
    );

class OrcamentoFormView extends GetView<OrcamentoController> {
  const OrcamentoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editando ? 'Editar orçamento' : 'Novo orçamento',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.ouro,
              strokeWidth: 2,
            ),
          );
        }

        final bloqueado = controller.aprovado.value;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (bloqueado) ...[
              const _AvisoAprovado(),
              const SizedBox(height: 16),
            ],
            AbsorbPointer(
              absorbing: bloqueado,
              child: Opacity(
                opacity: bloqueado ? 0.55 : 1,
                child: Column(
                  children: [
                    _Secao(
                      titulo: 'Cliente',
                      child: const _CampoCliente(),
                    ),
                    const SizedBox(height: 16),
                    _Secao(
                      titulo: 'Evento',
                      child: const _DadosEvento(),
                    ),
                    const SizedBox(height: 16),
                    _Secao(
                      titulo: 'Compra dos ingredientes',
                      child: const _SeletorCompradorIngredientes(),
                    ),
                    const SizedBox(height: 16),
                    _Secao(
                      titulo: 'Itens do orçamento',
                      acao: PopupMenuButton<String>(
                        tooltip: 'Adicionar item',
                        onSelected: (opcao) {
                          switch (opcao) {
                            case 'manual':
                              _abrirItem();
                              break;
                            case 'receita':
                              _selecionarReceitaEAdicionar();
                              break;
                            case 'servico':
                              _selecionarServicoEAdicionar();
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'manual',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Item manual'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'receita',
                            child: Row(
                              children: [
                                Icon(Icons.restaurant_menu_rounded),
                                SizedBox(width: 12),
                                Text('Adicionar receita'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'servico',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.room_service_outlined),
                              title: Text('Serviço do catálogo'),
                            ),
                          ),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: AppColors.roseGold,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Adicionar',
                                style: TextStyle(
                                  color: AppColors.roseGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: const _ListaItens(),
                    ),
                    const SizedBox(height: 16),
                    _Secao(
                      titulo: 'Desconto e observações',
                      child: const _Extras(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const _BarraTotal(),
    );
  }
}

class _AvisoAprovado extends StatelessWidget {
  const _AvisoAprovado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.champagne.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.roseGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este orçamento está confirmado e o evento já consta na '
              'agenda. Para alterar qualquer dado, abra o orçamento e use '
              '"Reabrir para editar".',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.texto.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _abrirItem({
  int? index,
  Servico? servico,
}) async {
  final controller = Get.find<OrcamentoController>();
  final itemAtual =
      index == null ? null : controller.itens.elementAtOrNull(index);

  final resultado = await Get.bottomSheet<ItemOrcamento>(
    _ItemSheet(
      item: itemAtual,
      servico: servico,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );

  if (resultado == null) return;

  if (index == null) {
    controller.adicionarItem(resultado);
  } else {
    controller.substituirItem(index, resultado);
  }
}

Future<void> _selecionarReceitaEAdicionar() async {
  final controller = Get.find<OrcamentoController>();

  if (controller.convidados.value <= 0) {
    Get.snackbar(
      'Informe os convidados',
      'Preencha o número de convidados antes de adicionar uma receita.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  try {
    final receitas = await controller.carregarReceitas();

    if (receitas.isEmpty) {
      Get.snackbar(
        'Nenhuma receita cadastrada',
        'Cadastre uma receita no Catálogo antes de adicioná-la ao orçamento.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final receita = await Get.bottomSheet<Receita>(
      _SeletorReceitaSheet(receitas: receitas),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (receita == null) return;

    await controller.adicionarReceitaAoFormulario(receita);

    Get.snackbar(
      'Receita adicionada',
      'Os ingredientes de "${receita.nome}" foram incluídos no orçamento.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (erro) {
    Get.snackbar(
      'Não foi possível adicionar a receita',
      erro.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

Future<void> _selecionarServicoEAdicionar() async {
  final controller = Get.find<OrcamentoController>();

  try {
    final servicos = await controller.carregarServicosAtivos();

    if (servicos.isEmpty) {
      Get.snackbar(
        'Nenhum serviço disponível',
        'Cadastre ou ative um serviço no Catálogo para adicioná-lo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final servico = await Get.bottomSheet<Servico>(
      _SeletorServicoSheet(servicos: servicos),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (servico == null) return;
    await _abrirItem(servico: servico);
  } catch (_) {
    Get.snackbar(
      'Erro',
      'Não foi possível carregar os serviços.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({
    required this.titulo,
    required this.child,
    this.acao,
  });

  final String titulo;
  final Widget child;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 17),
                ),
              ),
              ?acao,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SeletorCompradorIngredientes
    extends GetView<OrcamentoController> {
  const _SeletorCompradorIngredientes();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final compraBufe =
          controller.ingredientesCompradosPeloBufe.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quem será responsável por comprar os ingredientes?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.texto.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.champagne,
              selectedForegroundColor: AppColors.texto,
            ),
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Bufê'),
                icon: Icon(Icons.restaurant_rounded),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Cliente'),
                icon: Icon(Icons.person_outline_rounded),
              ),
            ],
            selected: {compraBufe},
            onSelectionChanged: (selecionado) {
              controller.definirQuemCompraIngredientes(
                selecionado.first,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            compraBufe
                ? 'Será cobrado o total dos ingredientes, mais 20% '
                    'para combustível e tempo.'
                : 'Os ingredientes e o adicional de 20% não serão '
                    'incluídos na cobrança do bufê.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.texto.withValues(alpha: 0.55),
            ),
          ),
        ],
      );
    });
  }
}

class _CampoCliente extends GetView<OrcamentoController> {
  const _CampoCliente();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cliente = controller.cliente.value;

      return PressableScale(
        onTap: () => Get.bottomSheet(
          const _SeletorClienteSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.fundo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.champagne,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.roseGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    cliente?.nome ?? 'Selecionar cliente',
                    key: ValueKey(cliente?.id),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cliente == null
                          ? AppColors.texto.withValues(alpha: 0.45)
                          : AppColors.texto,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.roseGold,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SeletorClienteSheet extends StatefulWidget {
  const _SeletorClienteSheet();

  @override
  State<_SeletorClienteSheet> createState() =>
      _SeletorClienteSheetState();
}

class _SeletorClienteSheetState extends State<_SeletorClienteSheet> {
  String _termo = '';

  @override
  Widget build(BuildContext context) {
    final clientesController = Get.find<ClientesController>();
    final orcamentoController = Get.find<OrcamentoController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.texto.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Escolher cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: clientesController.abrirFormulario,
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 18,
                ),
                label: const Text('Novo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.roseGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (valor) {
              setState(() {
                _termo = valor.trim().toLowerCase();
              });
            },
            decoration: _decoracao('Buscar', Icons.search_rounded),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final lista = clientesController.clientes
                  .where(
                    (cliente) =>
                        cliente.nome.toLowerCase().contains(_termo),
                  )
                  .toList();

              if (lista.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum cliente encontrado',
                    style: TextStyle(
                      color: AppColors.texto.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }

              return Material(
                type: MaterialType.transparency,
                child: ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final cliente = lista[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.champagne,
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.roseGold,
                        ),
                      ),
                      title: Text(
                        cliente.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: cliente.telefone == null
                          ? null
                          : Text(cliente.telefone!),
                      onTap: () {
                        orcamentoController.selecionarCliente(cliente);
                        Get.back();
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DadosEvento extends GetView<OrcamentoController> {
  const _DadosEvento();

  Future<void> _escolherData(BuildContext context) async {
    final atual = controller.dataEvento.value ?? DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2200),
      locale: const Locale('pt', 'BR'),
    );

    if (data == null || !context.mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(atual),
    );

    if (hora == null) return;

    controller.definirData(
      DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.tituloCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _decoracao(
            'Nome do evento',
            Icons.celebration_outlined,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final data = controller.dataEvento.value;

          return PressableScale(
            onTap: () => _escolherData(context),
            child: InputDecorator(
              decoration: _decoracao(
                'Data e horário',
                Icons.event_outlined,
              ),
              child: Text(
                data == null
                    ? 'Toque para escolher'
                    : '${dataCompleta(data)} às '
                        '${data.hour.toString().padLeft(2, '0')}:'
                        '${data.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: data == null
                      ? AppColors.texto.withValues(alpha: 0.45)
                      : AppColors.texto,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        TextField(
          controller: controller.localCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _decoracao(
            'Local',
            Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.convidadosCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: controller.definirConvidados,
          decoration: _decoracao(
            'Número de convidados',
            Icons.groups_outlined,
          ),
        ),
      ],
    );
  }
}

class _ListaItens extends GetView<OrcamentoController> {
  const _ListaItens();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lista = controller.itens.toList();
      final quantidadeConvidados = controller.convidados.value;

      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: lista.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhum item ainda. Adicione ingredientes ou serviços.',
                  style: TextStyle(
                    color: AppColors.texto.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              )
            : Column(
                children: [
                  for (var index = 0; index < lista.length; index++)
                    _ItemTile(
                      key: ObjectKey(lista[index]),
                      item: lista[index],
                      convidados: quantidadeConvidados,
                      onTap: () => _abrirItem(index: index),
                      onRemover: () => controller.removerItem(index),
                    ),
                ],
              ),
      );
    });
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.item,
    required this.convidados,
    required this.onTap,
    required this.onRemover,
  });

  final ItemOrcamento item;
  final int convidados;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final calculo = _descricaoCalculo(item, convidados);
    final ehIngrediente =
        item.categoria == ItemOrcamento.categoriaIngrediente;

    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemover(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.pendente.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFB5694A),
        ),
      ),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.fundo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    _TagCategoria(ingrediente: ehIngrediente),
                    if (item.receitaNome != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.receitaNome!,
                          style: const TextStyle(
                            color: AppColors.roseGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      calculo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.texto.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatarMoeda(item.totalCentavos(convidados)),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _descricaoCalculo(ItemOrcamento item, int convidados) {
    if (item.receitaId != null) {
      final quantidadeIngrediente = item.quantidadeMilesimos / 1000;
      final quantidadeTexto = _formatarQuantidade(quantidadeIngrediente);
      final unidade = item.unidade?.trim() ?? '';
      final quantidadeComUnidade = unidade.isEmpty
          ? quantidadeTexto
          : '$quantidadeTexto $unidade';

      return '$quantidadeComUnidade · ${item.receitaNome ?? 'Receita'}';
    }

    switch (item.tipoCobranca) {
      case ItemOrcamento.cobrancaPorConvidado:
        return '${formatarMoeda(item.precoCentavos)} × '
            '$convidados convidados';
      case ItemOrcamento.cobrancaPorUnidade:
        return '${formatarMoeda(item.precoCentavos)} × '
            '${item.quantidade} unidades';
      case ItemOrcamento.cobrancaGeral:
      default:
        return '${formatarMoeda(item.precoCentavos)} · valor geral';
    }
  }

  String _formatarQuantidade(double quantidade) {
    if (quantidade == quantidade.roundToDouble()) {
      return quantidade.toInt().toString();
    }

    return quantidade
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }
}

class _TagCategoria extends StatelessWidget {
  const _TagCategoria({required this.ingrediente});

  final bool ingrediente;

  @override
  Widget build(BuildContext context) {
    final cor = ingrediente ? AppColors.roseGold : AppColors.texto;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ingrediente
            ? AppColors.champagne.withValues(alpha: 0.65)
            : AppColors.fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ingrediente ? 'Ingrediente' : 'Serviço',
        style: TextStyle(
          color: cor.withValues(alpha: 0.85),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({
    this.item,
    this.servico,
  });

  final ItemOrcamento? item;
  final Servico? servico;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome = TextEditingController(
    text: widget.item?.nome ?? widget.servico?.nome ?? '',
  );

  late final TextEditingController _preco = TextEditingController(
    text: widget.item != null
        ? formatarMoeda(widget.item!.precoCentavos)
        : widget.servico?.precoCentavos == null
            ? ''
            : formatarMoeda(widget.servico!.precoCentavos!),
  );

  late final TextEditingController _quantidade = TextEditingController(
    text: '${widget.item?.quantidade ?? 1}',
  );

  late String _tipoCobranca = widget.item?.tipoCobranca ??
      widget.servico?.tipoCobranca ??
      ItemOrcamento.cobrancaGeral;

  late String _categoria = widget.item?.categoria ??
      (widget.servico == null
          ? ItemOrcamento.categoriaServico
          : ItemOrcamento.categoriaServico);

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
    _quantidade.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final base = widget.item;
    final nome = _nome.text.trim();
    final preco = centavosDoTexto(_preco.text);
    final quantidade = int.tryParse(_quantidade.text) ?? 1;

    final quantidadeAlterada =
        base != null && quantidade != base.quantidade;

    if (base != null &&
        base.nome == nome &&
        base.precoCentavos == preco &&
        base.quantidade == quantidade &&
        base.tipoCobranca == _tipoCobranca &&
        base.categoria == _categoria) {
      Get.back(result: base);
      return;
    }

    Get.back(
      result: ItemOrcamento(
        nome: nome,
        precoCentavos: preco,
        quantidade: quantidade,
        tipoCobranca: _tipoCobranca,
        categoria: _categoria,
        receitaId: quantidadeAlterada ? null : base?.receitaId,
        receitaIngredienteId:
            quantidadeAlterada ? null : base?.receitaIngredienteId,
        receitaNome: quantidadeAlterada ? null : base?.receitaNome,
        unidade: quantidadeAlterada ? null : base?.unidade,
        quantidadeMilesimos:
            quantidadeAlterada ? 1000 : (base?.quantidadeMilesimos ?? 1000),
        servicoId: base?.servicoId ?? widget.servico?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null ? 'Novo item' : 'Editar item',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoracao(
                    'Descrição',
                    Icons.restaurant_menu_rounded,
                  ),
                  validator: (valor) =>
                      valor == null || valor.trim().isEmpty
                          ? 'Informe a descrição'
                          : null,
                ),
                const SizedBox(height: 12),
                if (widget.servico == null) ...[
                  Text(
                    'Categoria do item',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.texto.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.champagne,
                        selectedForegroundColor: AppColors.texto,
                      ),
                      segments: const [
                        ButtonSegment<String>(
                          value: ItemOrcamento.categoriaIngrediente,
                          label: Text('Ingrediente'),
                        ),
                        ButtonSegment<String>(
                          value: ItemOrcamento.categoriaServico,
                          label: Text('Serviço'),
                        ),
                      ],
                      selected: {_categoria},
                      onSelectionChanged: (selecionados) {
                        setState(() {
                          _categoria = selecionados.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _preco,
                        keyboardType: TextInputType.number,
                        inputFormatters: [MoedaInputFormatter()],
                        decoration: _decoracao(
                          'Valor',
                          Icons.payments_outlined,
                        ),
                        validator: (valor) =>
                            centavosDoTexto(valor ?? '') <= 0
                                ? 'Informe um valor maior que zero'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantidade,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _decoracao(
                          'Qtd.',
                          Icons.tag_rounded,
                        ),
                        validator: (valor) =>
                            (int.tryParse(valor ?? '') ?? 0) <= 0
                                ? 'Mín. 1'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Forma de cobrança deste item',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.champagne,
                      selectedForegroundColor: AppColors.texto,
                    ),
                    segments: const [
                      ButtonSegment<String>(
                        value: ItemOrcamento.cobrancaPorUnidade,
                        label: Text('Unidade'),
                      ),
                      ButtonSegment<String>(
                        value: ItemOrcamento.cobrancaGeral,
                        label: Text('Geral'),
                      ),
                    ],
                    selected: {
                      _tipoCobranca ==
                              ItemOrcamento.cobrancaPorConvidado
                          ? ItemOrcamento.cobrancaGeral
                          : _tipoCobranca,
                    },
                    onSelectionChanged: (selecionados) {
                      setState(() {
                        _tipoCobranca = selecionados.first;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _confirmar,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ouro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Confirmar item'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Extras extends GetView<OrcamentoController> {
  const _Extras();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.descontoCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [MoedaInputFormatter()],
          onChanged: controller.definirDesconto,
          decoration: _decoracao(
            'Desconto',
            Icons.local_offer_outlined,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.obsCtrl,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: _decoracao(
            'Observações',
            Icons.sticky_note_2_outlined,
          ),
        ),
      ],
    );
  }
}

class _BarraTotal extends GetView<OrcamentoController> {
  const _BarraTotal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total do orçamento',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.texto.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        formatarMoeda(controller.totalCentavos),
                        key: ValueKey(controller.totalCentavos),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final salvando = controller.salvando.value;
              final bloqueado = controller.aprovado.value;

              return FilledButton(
                onPressed:
                    salvando || bloqueado ? null : controller.salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ouro,
                  minimumSize: const Size(130, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Salvar'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SeletorServicoSheet extends StatelessWidget {
  const _SeletorServicoSheet({required this.servicos});

  final List<Servico> servicos;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.texto.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Escolher serviço',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: servicos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final servico = servicos[index];
                final preco = servico.precoCentavos;

                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.champagne,
                      child: Icon(
                        Icons.room_service_outlined,
                        color: AppColors.roseGold,
                      ),
                    ),
                    title: Text(
                      servico.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${preco == null ? 'Sem preço sugerido' : formatarMoeda(preco)}'
                      ' · ${_rotuloCobranca(servico.tipoCobranca)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.back(result: servico),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _rotuloCobranca(String tipo) {
    switch (tipo) {
      case ItemOrcamento.cobrancaPorConvidado:
        return 'por convidado';
      case ItemOrcamento.cobrancaPorUnidade:
        return 'por unidade';
      default:
        return 'valor geral';
    }
  }
}

class _SeletorReceitaSheet extends StatelessWidget {
  const _SeletorReceitaSheet({required this.receitas});

  final List<Receita> receitas;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.texto.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Escolher receita',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: receitas.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final receita = receitas[index];

                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.champagne,
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.roseGold,
                      ),
                    ),
                    title: Text(
                      receita.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Rendimento: ${receita.rendimentoPessoas} pessoas',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.back(result: receita),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}