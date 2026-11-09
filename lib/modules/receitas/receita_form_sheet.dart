import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';

class ReceitaIngredienteFormulario {
  const ReceitaIngredienteFormulario({
    required this.produto,
    required this.quantidadeMilesimos,
    required this.unidade,
    required this.precoCentavos,
  });

  final String produto;
  final int quantidadeMilesimos;
  final String unidade;
  final int? precoCentavos;
}

class ReceitaFormularioResultado {
  const ReceitaFormularioResultado({
    required this.nome,
    required this.rendimentoPessoas,
    required this.ingredientes,
  });

  final String nome;
  final int rendimentoPessoas;
  final List<ReceitaIngredienteFormulario> ingredientes;
}

class ReceitaFormSheet extends StatefulWidget {
  const ReceitaFormSheet({
    super.key,
    this.receita,
    this.ingredientes = const [],
  });

  final Receita? receita;
  final List<ReceitaIngrediente> ingredientes;

  bool get editando => receita != null;

  @override
  State<ReceitaFormSheet> createState() => _ReceitaFormSheetState();
}

class _ReceitaFormSheetState extends State<ReceitaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _rendimentoController;
  final List<_IngredienteCampos> _ingredientes = [];

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.receita?.nome ?? '');
    _rendimentoController = TextEditingController(
      text: widget.receita?.rendimentoPessoas.toString() ?? '',
    );

    for (final ingrediente in widget.ingredientes) {
      _ingredientes.add(
        _IngredienteCampos(
          produto: ingrediente.produto,
          quantidadeMilesimos: ingrediente.quantidadeMilesimos,
          unidade: ingrediente.unidade,
          precoCentavos: ingrediente.precoCentavos,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _rendimentoController.dispose();
    for (final ingrediente in _ingredientes) {
      ingrediente.dispose();
    }
    super.dispose();
  }

  Future<void> _abrirEditorIngrediente({int? index}) async {
    final ingrediente = index == null ? null : _ingredientes[index];
    final resultado = await showDialog<_IngredienteDraft>(
      context: context,
      builder: (_) => _IngredienteEditorDialog(
        ingrediente: ingrediente,
        numero: index == null ? _ingredientes.length + 1 : index + 1,
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      final novoIngrediente = _IngredienteCampos(
        produto: resultado.produto,
        quantidadeMilesimos: resultado.quantidadeMilesimos,
        unidade: resultado.unidade,
        precoCentavos: resultado.precoCentavos,
      );

      if (index == null) {
        _ingredientes.add(novoIngrediente);
      } else {
        final anterior = _ingredientes[index];
        _ingredientes[index] = novoIngrediente;
        anterior.dispose();
      }
    });
  }

  void _removerIngrediente(int index) {
    if (_ingredientes.length <= 1) {
      _mostrarErro('A receita precisa ter pelo menos um ingrediente.');
      return;
    }

    final ingrediente = _ingredientes.removeAt(index);
    ingrediente.dispose();
    setState(() {});
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final nome = _nomeController.text.trim();
    final rendimento = int.tryParse(_rendimentoController.text.trim());

    if (rendimento == null || rendimento <= 0) {
      _mostrarErro('Informe um rendimento válido.');
      return;
    }

    if (_ingredientes.isEmpty) {
      _mostrarErro('Adicione pelo menos um ingrediente.');
      return;
    }

    final ingredientes = _ingredientes.map((campos) {
      return ReceitaIngredienteFormulario(
        produto: campos.produto.text.trim(),
        quantidadeMilesimos: campos.quantidadeMilesimos,
        unidade: campos.unidade,
        precoCentavos: campos.precoCentavos,
      );
    }).toList();

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      ReceitaFormularioResultado(
        nome: nome,
        rendimentoPessoas: rendimento,
        ingredientes: ingredientes,
      ),
    );
  }

  InputDecoration _decoracao({
    required String rotulo,
    String? dica,
    String? sufixo,
  }) {
    return InputDecoration(
      labelText: rotulo,
      hintText: dica,
      suffixText: sufixo,
      filled: true,
      fillColor: AppColors.fundo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.champagne.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ouro, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.sizeOf(context).height * 0.92;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: alturaMaxima),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.superficie,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.texto.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.editando ? 'Editar receita' : 'Nova receita',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: _decoracao(
                            rotulo: 'Nome da receita',
                            dica: 'Ex.: Feijão Gordo',
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o nome da receita.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _rendimentoController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _decoracao(
                            rotulo: 'Rendimento',
                            dica: 'Quantidade de pessoas',
                            sufixo: 'pessoas',
                          ),
                          validator: (valor) {
                            final numero = int.tryParse(valor?.trim() ?? '');
                            if (numero == null || numero <= 0) {
                              return 'Informe um rendimento válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Ingredientes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.texto,
                                ),
                              ),
                            ),
                            Text(
                              '${_ingredientes.length}',
                              style: TextStyle(
                                color: AppColors.texto.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Toque em um ingrediente para editar os dados.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.texto.withValues(alpha: 0.58),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_ingredientes.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.fundo,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.champagne),
                            ),
                            child: Text(
                              'Ainda não há ingredientes. Use o botão abaixo '
                              'para adicionar o primeiro.',
                              style: TextStyle(
                                height: 1.4,
                                color: AppColors.texto.withValues(alpha: 0.68),
                              ),
                            ),
                          )
                        else
                          for (var i = 0; i < _ingredientes.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _buildIngredienteResumo(i),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirEditorIngrediente(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Adicionar ingrediente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.roseGold,
                      side: const BorderSide(color: AppColors.champagne),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _salvar,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ouro,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.editando
                          ? 'Salvar alterações'
                          : 'Cadastrar receita',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredienteResumo(int index) {
    final ingrediente = _ingredientes[index];
    final preco = ingrediente.precoCentavos == null
        ? null
        : 'R\$ ${_formatarPreco(ingrediente.precoCentavos!)}';

    return Material(
      color: AppColors.fundo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _abrirEditorIngrediente(index: index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 4, 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.champagne),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.champagne,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.texto,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingrediente.produto.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatarQuantidade(ingrediente.quantidadeMilesimos)} '
                      '${ingrediente.unidade}'
                      '${preco == null ? '' : '  •  $preco'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.texto.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remover ingrediente',
                visualDensity: VisualDensity.compact,
                onPressed: () => _removerIngrediente(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.roseGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredienteEditorDialog extends StatefulWidget {
  const _IngredienteEditorDialog({required this.numero, this.ingrediente});

  final int numero;
  final _IngredienteCampos? ingrediente;

  @override
  State<_IngredienteEditorDialog> createState() =>
      _IngredienteEditorDialogState();
}

class _IngredienteEditorDialogState extends State<_IngredienteEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _produtoController;
  late final TextEditingController _quantidadeController;
  late final TextEditingController _unidadeController;
  late final TextEditingController _precoController;

  @override
  void initState() {
    super.initState();
    final ingrediente = widget.ingrediente;
    _produtoController = TextEditingController(
      text: ingrediente?.produto.text ?? '',
    );
    _quantidadeController = TextEditingController(
      text: ingrediente == null
          ? ''
          : _formatarQuantidade(ingrediente.quantidadeMilesimos),
    );
    _unidadeController = TextEditingController(
      text: ingrediente?.unidade ?? '',
    );
    _precoController = TextEditingController(
      text: ingrediente?.precoCentavos == null
          ? ''
          : _formatarPreco(ingrediente!.precoCentavos!),
    );
  }

  @override
  void dispose() {
    _produtoController.dispose();
    _quantidadeController.dispose();
    _unidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final quantidade = _lerQuantidade(_quantidadeController.text)!;
    final precoTexto = _precoController.text.trim();
    final precoCentavos = precoTexto.isEmpty
        ? null
        : _lerPrecoCentavos(precoTexto);

    Navigator.of(context).pop(
      _IngredienteDraft(
        produto: _produtoController.text.trim(),
        quantidadeMilesimos: (quantidade * 1000).round(),
        unidade: _unidadeController.text.trim(),
        precoCentavos: precoCentavos,
      ),
    );
  }

  InputDecoration _decoracao(String rotulo, {String? dica, String? prefixo}) {
    return InputDecoration(
      labelText: rotulo,
      hintText: dica,
      prefixText: prefixo,
      filled: true,
      fillColor: AppColors.fundo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.champagne.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.ouro, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.ingrediente == null
            ? 'Novo ingrediente'
            : 'Editar ingrediente',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _produtoController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _decoracao('Produto', dica: 'Ex.: Feijão Carioca'),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe o produto.'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantidadeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: _decoracao('Quantidade', dica: 'Ex.: 2'),
                    validator: (valor) {
                      final quantidade = _lerQuantidade(valor ?? '');
                      if (quantidade == null || quantidade <= 0) {
                        return 'Informe uma quantidade válida.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _unidadeController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracao('Unidade', dica: 'kg'),
                    validator: (valor) => valor == null || valor.trim().isEmpty
                        ? 'Informe a unidade.'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _confirmar(),
              decoration: _decoracao('Preço estimado',
                  dica: 'Opcional', prefixo: 'R\$ '),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return null;
                if (_lerPrecoCentavos(valor) == null) {
                  return 'Informe um preço válido.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ouro,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.ingrediente == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }
}

class _IngredienteDraft {
  const _IngredienteDraft({
    required this.produto,
    required this.quantidadeMilesimos,
    required this.unidade,
    required this.precoCentavos,
  });

  final String produto;
  final int quantidadeMilesimos;
  final String unidade;
  final int? precoCentavos;
}

class _IngredienteCampos {
  _IngredienteCampos({
    required String produto,
    required this.quantidadeMilesimos,
    required this.unidade,
    required this.precoCentavos,
  }) : produto = TextEditingController(text: produto);

  final TextEditingController produto;
  final int quantidadeMilesimos;
  final String unidade;
  final int? precoCentavos;

  void dispose() => produto.dispose();
}

double? _lerQuantidade(String texto) {
  var valor = texto.trim().replaceAll(' ', '');
  if (valor.isEmpty) return null;

  if (valor.contains(',') && valor.contains('.')) {
    valor = valor.replaceAll('.', '').replaceAll(',', '.');
  } else {
    valor = valor.replaceAll(',', '.');
  }

  return double.tryParse(valor);
}

int? _lerPrecoCentavos(String texto) {
  var valor = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
  if (valor.isEmpty) return null;

  if (valor.contains(',') && valor.contains('.')) {
    valor = valor.replaceAll('.', '').replaceAll(',', '.');
  } else {
    valor = valor.replaceAll(',', '.');
  }

  final numero = double.tryParse(valor);
  if (numero == null || numero < 0) return null;
  return (numero * 100).round();
}

String _formatarQuantidade(int milesimos) {
  final valor = milesimos / 1000;
  if (valor == valor.truncateToDouble()) return valor.toInt().toString();

  return valor
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
}

String _formatarPreco(int centavos) =>
    (centavos / 100).toStringAsFixed(2).replaceAll('.', ',');
