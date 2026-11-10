import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class ClienteFormResultado {
  const ClienteFormResultado({
    required this.nome,
    required this.telefone,
    required this.email,
  });

  final String nome;
  final String telefone;
  final String email;
}

class ClienteFormSheet extends StatefulWidget {
  const ClienteFormSheet({
    super.key,
    this.nome = '',
    this.telefone = '',
    this.email = '',
    this.editando = false,
  });

  final String nome;
  final String telefone;
  final String email;
  final bool editando;

  @override
  State<ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends State<ClienteFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.nome);
    _telefone = TextEditingController(
      text: _formatarTelefone(widget.telefone.replaceAll(RegExp(r'\D'), '')),
    );
    _email = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(
      ClienteFormResultado(
        nome: _nome.text.trim(),
        telefone: _telefone.text.trim(),
        email: _email.text.trim(),
      ),
    );
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.champagne.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.ouro,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.terracota),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.terracota,
          width: 1.2,
        ),
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),
                  Text(
                    widget.editando ? 'Editar cliente' : 'Novo cliente',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nome,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracao(
                      'Nome',
                      Icons.person_outline_rounded,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o nome do cliente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [const _TelefoneInputFormatter()],
                    decoration: _decoracao(
                      'Telefone',
                      Icons.phone_outlined,
                    ).copyWith(hintText: '(11) 99999-9999'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _confirmar(),
                    decoration: _decoracao(
                      'E-mail',
                      Icons.email_outlined,
                    ),
                    validator: (valor) {
                      final texto = valor?.trim() ?? '';
                      if (texto.isEmpty) return null;

                      final emailValido =
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(texto);

                      return emailValido ? null : 'E-mail inválido';
                    },
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.texto,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _confirmar,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.ouro,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.editando ? 'Salvar' : 'Cadastrar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatarTelefone(String digitos) {
    final numero = digitos.length > 11 ? digitos.substring(0, 11) : digitos;
    if (numero.isEmpty) return '';

    if (numero.length <= 2) {
      return numero.length == 2 ? '($numero) ' : '($numero';
    }

    final ddd = numero.substring(0, 2);
    final restante = numero.substring(2);
    final tamanhoPrefixo = numero.length > 10 ? 5 : 4;
    final base = '($ddd) ';

    if (restante.length <= tamanhoPrefixo) {
      return '$base$restante';
    }

    return '$base${restante.substring(0, tamanhoPrefixo)}-'
        '${restante.substring(tamanhoPrefixo)}';
  }
}

class _TelefoneInputFormatter extends TextInputFormatter {
  const _TelefoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final cursorOffset = newValue.selection.extentOffset
        .clamp(0, newValue.text.length)
        .toInt();
    var digitsBeforeCursor = newValue.text
        .substring(0, cursorOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Se o usuário apaga um separador da máscara, remove também o dígito
    // adjacente. Assim o cursor não fica preso nos parênteses ou no espaço
    // do DDD, impedindo que ele seja corrigido com a tecla de apagar.
    if (newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length) {
      var prefixLength = 0;
      while (prefixLength < oldValue.text.length &&
          prefixLength < newValue.text.length &&
          oldValue.text[prefixLength] == newValue.text[prefixLength]) {
        prefixLength++;
      }

      var suffixLength = 0;
      while (suffixLength < oldValue.text.length - prefixLength &&
          suffixLength < newValue.text.length - prefixLength &&
          oldValue.text[oldValue.text.length - 1 - suffixLength] ==
              newValue.text[newValue.text.length - 1 - suffixLength]) {
        suffixLength++;
      }

      final removido = oldValue.text.substring(
        prefixLength,
        oldValue.text.length - suffixLength,
      );

      if (removido.isNotEmpty && !RegExp(r'\d').hasMatch(removido)) {
        final digitsBeforeDeletion = oldValue.text
            .substring(0, prefixLength)
            .replaceAll(RegExp(r'\D'), '')
            .length;
        final indexToRemove = digitsBeforeDeletion > 0
            ? digitsBeforeDeletion - 1
            : 0;

        if (digits.isNotEmpty && indexToRemove < digits.length) {
          digits = digits.replaceRange(indexToRemove, indexToRemove + 1, '');
          digitsBeforeCursor = indexToRemove;
        }
      }
    }

    if (digits.length > 11) digits = digits.substring(0, 11);
    if (digitsBeforeCursor > digits.length) {
      digitsBeforeCursor = digits.length;
    }

    final formatted = _ClienteFormSheetState._formatarTelefone(digits);
    final offset = _cursorOffset(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  int _cursorOffset(String text, int digitsBeforeCursor) {
    if (digitsBeforeCursor <= 0) return 0;
    if (digitsBeforeCursor == text.replaceAll(RegExp(r'\D'), '').length) {
      return text.length;
    }

    var digitsFound = 0;
    for (var index = 0; index < text.length; index++) {
      if (RegExp(r'\d').hasMatch(text[index])) {
        digitsFound++;
        if (digitsFound == digitsBeforeCursor) return index + 1;
      }
    }
    return text.length;
  }
}

