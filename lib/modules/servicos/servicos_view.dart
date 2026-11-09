import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/moeda_input_formatter.dart';
import '../../data/database/app_database.dart';
import 'servicos_controller.dart';

class ServicosView extends GetView<ServicosController> {
  const ServicosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: Text(
          'Serviços',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.carregando.value && controller.servicos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.ouro),
          );
        }

        if (controller.servicos.isEmpty) {
          return const _EstadoVazio();
        }

        return RefreshIndicator(
          color: AppColors.ouro,
          onRefresh: controller.carregar,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: controller.servicos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final servico = controller.servicos[index];

              return _ServicoCard(
                nome: servico.nome,
                precoCentavos: servico.precoCentavos,
                tipoCobranca: servico.tipoCobranca,
                ativo: servico.ativo,
                onTap: () => _abrirFormulario(servico: servico),
                onAtivoChanged: (_) =>
                    controller.alternarAtivo(servico),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.ouro,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo serviço'),
      ),
    );
  }

  Future<void> _abrirFormulario({Servico? servico}) async {
    await Get.bottomSheet<void>(
      _ServicoFormSheet(servico: servico),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.champagne,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.room_service_outlined,
                color: AppColors.roseGold,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Seu catálogo começa aqui',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre serviços recorrentes para adicioná-los '
              'rapidamente aos orçamentos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                color: AppColors.texto.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  const _ServicoCard({
    required this.nome,
    required this.precoCentavos,
    required this.tipoCobranca,
    required this.ativo,
    required this.onTap,
    required this.onAtivoChanged,
  });

  final String nome;
  final int? precoCentavos;
  final String tipoCobranca;
  final bool ativo;
  final VoidCallback onTap;
  final ValueChanged<bool> onAtivoChanged;

  @override
  Widget build(BuildContext context) {
    final preco = precoCentavos == null
        ? 'Sem preço sugerido'
        : formatarMoeda(precoCentavos!);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: ativo ? 1 : 0.58,
      child: Material(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.sombraSutil,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: ativo ? AppColors.champagne : AppColors.fundo,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.room_service_outlined,
                    color: ativo
                        ? AppColors.roseGold
                        : AppColors.texto.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.texto,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$preco · ${_rotuloCobranca(tipoCobranca)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.texto.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: ativo,
                  activeTrackColor: AppColors.ouro,
                  onChanged: onAtivoChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _rotuloCobranca(String tipo) {
    switch (tipo) {
      case 'porConvidado':
        return 'por convidado';
      case 'porUnidade':
        return 'por unidade';
      default:
        return 'valor geral';
    }
  }
}

class _ServicoFormSheet extends StatefulWidget {
  const _ServicoFormSheet({this.servico});

  final Servico? servico;

  @override
  State<_ServicoFormSheet> createState() => _ServicoFormSheetState();
}

class _ServicoFormSheetState extends State<_ServicoFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome = TextEditingController(
    text: widget.servico?.nome ?? '',
  );

  late final TextEditingController _preco = TextEditingController(
    text: widget.servico?.precoCentavos == null
        ? ''
        : formatarMoeda(widget.servico!.precoCentavos!),
  );

  late String _tipoCobranca =
      widget.servico?.tipoCobranca ?? 'geral';

  late bool _ativo = widget.servico?.ativo ?? true;
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    try {
      await Get.find<ServicosController>().salvar(
        id: widget.servico?.id,
        nome: _nome.text,
        precoTexto: _preco.text,
        tipoCobranca: _tipoCobranca,
        ativo: _ativo,
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
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
                    widget.servico == null
                        ? 'Cadastrar serviço'
                        : 'Editar serviço',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nome,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracao(
                      'Nome do serviço',
                      Icons.room_service_outlined,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o nome do serviço';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _preco,
                    keyboardType: TextInputType.number,
                    inputFormatters: [MoedaInputFormatter()],
                    textInputAction: TextInputAction.done,
                    decoration: _decoracao(
                      'Preço sugerido (opcional)',
                      Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Cobrança sugerida',
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
                        ButtonSegment(
                          value: 'porConvidado',
                          label: Text('Convidado'),
                        ),
                        ButtonSegment(
                          value: 'porUnidade',
                          label: Text('Unidade'),
                        ),
                        ButtonSegment(
                          value: 'geral',
                          label: Text('Geral'),
                        ),
                      ],
                      selected: {_tipoCobranca},
                      onSelectionChanged: (selecionados) {
                        setState(() {
                          _tipoCobranca = selecionados.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.ouro,
                    title: const Text(
                      'Disponível para novos orçamentos',
                    ),
                    value: _ativo,
                    onChanged: (valor) {
                      setState(() => _ativo = valor);
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ouro,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar serviço'),
                    ),
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