import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/moeda_input_formatter.dart';
import '../../../data/database/app_database.dart';
import '../orcamento_controller.dart';

class OrcamentoItemEditorMenu extends StatelessWidget {
  const OrcamentoItemEditorMenu({
    super.key,
    required this.onItemManual,
    required this.onReceita,
    required this.onServico,
    this.enabled = true,
  });

  final VoidCallback onItemManual;
  final VoidCallback onReceita;
  final VoidCallback onServico;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: 'Adicionar item',
      onSelected: (opcao) {
        switch (opcao) {
          case 'manual':
            onItemManual();
          case 'receita':
            onReceita();
          case 'servico':
            onServico();
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
    );
  }
}

class OrcamentoItemEditorSheet extends StatefulWidget {
  const OrcamentoItemEditorSheet({
    super.key,
    this.item,
    this.servico,
  });

  final ItemOrcamento? item;
  final Servico? servico;

  @override
  State<OrcamentoItemEditorSheet> createState() =>
      _OrcamentoItemEditorSheetState();
}

class _OrcamentoItemEditorSheetState extends State<OrcamentoItemEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController =
      TextEditingController(
    text: widget.item?.nome ?? widget.servico?.nome ?? '',
  );

  late final TextEditingController _precoController =
      TextEditingController(
    text: widget.item != null
        ? formatarMoeda(widget.item!.precoCentavos)
        : widget.servico?.precoCentavos == null
            ? ''
            : formatarMoeda(widget.servico!.precoCentavos!),
  );

  late final TextEditingController _quantidadeController =
      TextEditingController(
    text: '${widget.item?.quantidade ?? 1}',
  );

  late String _tipoCobranca = widget.item?.tipoCobranca ??
      widget.servico?.tipoCobranca ??
      ItemOrcamento.cobrancaGeral;

  late String _categoria = widget.item?.categoria ??
      ItemOrcamento.categoriaServico;

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  InputDecoration _decoracao(String rotulo, IconData icone) {
    return InputDecoration(
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
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final base = widget.item;
    final nome = _nomeController.text.trim();
    final precoCentavos = centavosDoTexto(_precoController.text);
    final quantidade = int.tryParse(_quantidadeController.text) ?? 1;
    final quantidadeAlterada =
        base != null && quantidade != base.quantidade;

    final semAlteracoes = base != null &&
        base.nome == nome &&
        base.precoCentavos == precoCentavos &&
        base.quantidade == quantidade &&
        base.tipoCobranca == _tipoCobranca &&
        base.categoria == _categoria;

    if (semAlteracoes) {
      Get.back<ItemOrcamento>(result: base);
      return;
    }

    Get.back<ItemOrcamento>(
      result: ItemOrcamento(
        nome: nome,
        precoCentavos: precoCentavos,
        quantidade: quantidade,
        tipoCobranca: _tipoCobranca,
        categoria: widget.servico == null
            ? _categoria
            : ItemOrcamento.categoriaServico,
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
                  controller: _nomeController,
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
                        controller: _precoController,
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
                        controller: _quantidadeController,
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
                      _tipoCobranca == ItemOrcamento.cobrancaPorConvidado
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

class OrcamentoReceitaSelectorSheet extends StatelessWidget {
  const OrcamentoReceitaSelectorSheet({
    super.key,
    required this.receitas,
    required this.subtitulo,
  });

  final List<Receita> receitas;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return _SelectorSheetFrame(
      titulo: 'Escolher receita',
      subtitulo: subtitulo,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: receitas.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final receita = receitas[index];

          return ListTile(
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
            onTap: () => Get.back<Receita>(result: receita),
          );
        },
      ),
    );
  }
}

class OrcamentoServicoSelectorSheet extends StatelessWidget {
  const OrcamentoServicoSelectorSheet({
    super.key,
    required this.servicos,
  });

  final List<Servico> servicos;

  @override
  Widget build(BuildContext context) {
    return _SelectorSheetFrame(
      titulo: 'Escolher serviço',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: servicos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final servico = servicos[index];
          final preco = servico.precoCentavos;

          return ListTile(
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
              ' · ${_rotuloTipoCobranca(servico.tipoCobranca)}',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Get.back<Servico>(result: servico),
          );
        },
      ),
    );
  }

  String _rotuloTipoCobranca(String tipoCobranca) {
    switch (tipoCobranca) {
      case ItemOrcamento.cobrancaPorConvidado:
        return 'por convidado';
      case ItemOrcamento.cobrancaPorUnidade:
        return 'por unidade';
      default:
        return 'valor geral';
    }
  }
}

class _SelectorSheetFrame extends StatelessWidget {
  const _SelectorSheetFrame({
    required this.titulo,
    required this.child,
    this.subtitulo,
  });

  final String titulo;
  final String? subtitulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.texto.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitulo!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.texto.withValues(alpha: 0.58),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}