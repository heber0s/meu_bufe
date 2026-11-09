import 'package:flutter/material.dart';

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
    _telefone = TextEditingController(text: widget.telefone);
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
                    decoration: _decoracao(
                      'Telefone',
                      Icons.phone_outlined,
                    ),
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
}