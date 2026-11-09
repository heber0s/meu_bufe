import 'package:flutter/material.dart';

class ProdutoFormularioResultado {
  const ProdutoFormularioResultado({
    required this.nome,
    required this.quantidadeMilesimos,
    required this.unidade,
    required this.precoCentavos,
  });

  final String nome;
  final int quantidadeMilesimos;
  final String unidade;
  final int precoCentavos;
}

class ProdutoFormDialog extends StatefulWidget {
  const ProdutoFormDialog({
    super.key,
    required this.titulo,
    required this.textoBotao,
    this.nome = '',
    this.quantidade = '1',
    this.unidade = 'un',
    this.preco = '',
    this.avisoReceita,
  });

  final String titulo;
  final String textoBotao;
  final String nome;
  final String quantidade;
  final String unidade;
  final String preco;

  /// Se informado, mostra o aviso de que o item deixará de ser da receita.
  final String? avisoReceita;

  @override
  State<ProdutoFormDialog> createState() => _ProdutoFormDialogState();
}

class _ProdutoFormDialogState extends State<ProdutoFormDialog> {
  late final TextEditingController _nome;
  late final TextEditingController _quantidade;
  late final TextEditingController _unidade;
  late final TextEditingController _preco;

  String? _erroNome;
  String? _erroQuantidade;
  String? _erroUnidade;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.nome);
    _quantidade = TextEditingController(text: widget.quantidade);
    _unidade = TextEditingController(text: widget.unidade);
    _preco = TextEditingController(text: widget.preco);
  }

  @override
  void dispose() {
    _nome.dispose();
    _quantidade.dispose();
    _unidade.dispose();
    _preco.dispose();
    super.dispose();
  }

  double? _lerDouble(String texto) {
    var valor = texto.trim().replaceAll(' ', '');
    if (valor.isEmpty) return null;

    if (valor.contains(',') && valor.contains('.')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    } else {
      valor = valor.replaceAll(',', '.');
    }
    return double.tryParse(valor);
  }

  int _lerCentavos(String texto) {
    final valor = _lerDouble(texto.replaceAll('R\$', ''));
    return valor == null ? 0 : (valor * 100).round();
  }

  void _confirmar() {
    final nome = _nome.text.trim();
    final quantidade = _lerDouble(_quantidade.text);
    final unidade = _unidade.text.trim();

    setState(() {
      _erroNome = nome.isEmpty ? 'Informe o nome do produto' : null;
      _erroQuantidade = (quantidade == null || quantidade <= 0)
          ? 'Quantidade inválida'
          : null;
      _erroUnidade = unidade.isEmpty ? 'Informe a unidade' : null;
    });

    if (_erroNome != null || _erroQuantidade != null || _erroUnidade != null) {
      return;
    }

    Navigator.of(context).pop(
      ProdutoFormularioResultado(
        nome: nome,
        quantidadeMilesimos: (quantidade! * 1000).round(),
        unidade: unidade,
        precoCentavos: _lerCentavos(_preco.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.avisoReceita != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E7CE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded,
                        size: 18, color: Color(0xFFB76E79)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.avisoReceita!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFB76E79)),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Produto',
                errorText: _erroNome,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantidade,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      errorText: _erroQuantidade,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _unidade,
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      errorText: _erroUnidade,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _preco,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Preço',
                prefixText: 'R\$ ',
              ),
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
          child: Text(widget.textoBotao),
        ),
      ],
    );
  }
}