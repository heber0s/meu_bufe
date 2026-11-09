import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../../core/theme/app_theme.dart';
import '../orcamento_detalhe_controller.dart';

class OrcamentoAcompanhamentoSection extends StatelessWidget {
  const OrcamentoAcompanhamentoSection({
    required this.controller,
    super.key,
  });

  final OrcamentoDetalheController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final registros = controller.acompanhamentos.toList();
      final retorno = registros.isEmpty ? null : registros.first.proximoRetorno;
      final aprovado = controller.aprovado;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.champagne.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.forum_outlined,
                    color: AppColors.roseGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acompanhamento',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Registre contatos e organize o próximo retorno.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.texto.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (retorno != null) ...[
              const SizedBox(height: 14),
              _RetornoBanner(data: retorno),
            ],
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: aprovado ? null : () => _abrirFormulario(context),
                icon: const Icon(Icons.add_comment_outlined),
                label: Text(
                  aprovado ? 'Orçamento aprovado' : 'Registrar contato',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.roseGold,
                  side: BorderSide(
                    color: AppColors.roseGold.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (registros.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Divider(height: 1),
              ),
              const Text(
                'Histórico de contatos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < registros.length; i++) ...[
                _ContatoItem(registro: registros[i]),
                if (i < registros.length - 1)
                  const Divider(height: 16, indent: 42),
              ],
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Ainda não há contatos registrados para este orçamento.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.texto.withValues(alpha: 0.62),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _abrirFormulario(BuildContext context) async {
    final resultado = await showDialog<_NovoAcompanhamento>(
      context: context,
      builder: (_) => const _FormularioAcompanhamento(),
    );
    if (resultado == null) return;

    await controller.registrarAcompanhamento(
      canal: resultado.canal,
      resumo: resultado.resumo,
      proximoRetorno: resultado.proximoRetorno,
    );
  }
}

class _RetornoBanner extends StatelessWidget {
  const _RetornoBanner({required this.data});

  final DateTime data;

  @override
  Widget build(BuildContext context) {
    final atrasado = data.isBefore(DateTime.now());
    final cor = atrasado ? AppColors.terracota : AppColors.sage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            atrasado ? Icons.notification_important_outlined : Icons.notifications_active_outlined,
            size: 18,
            color: cor,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '${atrasado ? 'Retorno atrasado' : 'Próximo retorno'} · ${_formatarDataHora(data)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContatoItem extends StatelessWidget {
  const _ContatoItem({required this.registro});

  final OrcamentoAcompanhamento registro;

  @override
  Widget build(BuildContext context) {
    final icone = switch (registro.canal) {
      'WhatsApp' => Icons.chat_outlined,
      'Ligação' => Icons.call_outlined,
      'E-mail' => Icons.mail_outline,
      'Presencial' => Icons.people_outline,
      _ => Icons.more_horiz_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.fundo,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icone, size: 18, color: AppColors.roseGold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${registro.canal} · ${_formatarDataHora(registro.contatoEm)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  registro.resumo,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.texto.withValues(alpha: 0.72),
                  ),
                ),
                if (registro.proximoRetorno != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Retorno: ${_formatarDataHora(registro.proximoRetorno!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.roseGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NovoAcompanhamento {
  const _NovoAcompanhamento({
    required this.canal,
    required this.resumo,
    required this.proximoRetorno,
  });

  final String canal;
  final String resumo;
  final DateTime? proximoRetorno;
}

class _FormularioAcompanhamento extends StatefulWidget {
  const _FormularioAcompanhamento();

  @override
  State<_FormularioAcompanhamento> createState() =>
      _FormularioAcompanhamentoState();
}

class _FormularioAcompanhamentoState extends State<_FormularioAcompanhamento> {
  final _formKey = GlobalKey<FormState>();
  final _resumoController = TextEditingController();
  String _canal = 'WhatsApp';
  late DateTime? _proximoRetorno;

  @override
  void initState() {
    super.initState();
    final sugerido = DateTime.now().add(const Duration(days: 3));
    _proximoRetorno = DateTime(
      sugerido.year,
      sugerido.month,
      sugerido.day,
      9,
    );
  }

  @override
  void dispose() {
    _resumoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataRetorno = _proximoRetorno;
    return AlertDialog(
      title: const Text('Registrar contato'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _canal,
                decoration: const InputDecoration(
                  labelText: 'Canal de contato',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'Ligação', child: Text('Ligação')),
                  DropdownMenuItem(value: 'E-mail', child: Text('E-mail')),
                  DropdownMenuItem(value: 'Presencial', child: Text('Presencial')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (valor) {
                  if (valor != null) setState(() => _canal = valor);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _resumoController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Resumo do contato',
                  hintText: 'Ex.: cliente pediu ajuste na quantidade de convidados',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe um breve resumo.'
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Lembrete de retorno',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 7),
              OutlinedButton.icon(
                onPressed: _selecionarRetorno,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  dataRetorno == null
                      ? 'Escolher data e horário'
                      : _formatarDataHora(dataRetorno),
                ),
              ),
              if (dataRetorno != null)
                TextButton.icon(
                  onPressed: () => setState(() => _proximoRetorno = null),
                  icon: const Icon(Icons.notifications_off_outlined, size: 17),
                  label: const Text('Salvar sem lembrete'),
                ),
              if (dataRetorno == null)
                TextButton.icon(
                  onPressed: _selecionarRetorno,
                  icon: const Icon(Icons.notifications_active_outlined, size: 17),
                  label: const Text('Adicionar lembrete'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: const Text('Salvar contato'),
        ),
      ],
    );
  }

  Future<void> _selecionarRetorno() async {
    final inicial = _proximoRetorno ?? DateTime.now().add(const Duration(days: 3));
    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Escolha a data do retorno',
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: _proximoRetorno == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay.fromDateTime(_proximoRetorno!),
      helpText: 'Escolha o horário do retorno',
    );
    if (hora == null || !mounted) return;

    setState(() {
      _proximoRetorno = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _NovoAcompanhamento(
        canal: _canal,
        resumo: _resumoController.text.trim(),
        proximoRetorno: _proximoRetorno,
      ),
    );
  }
}

String _formatarDataHora(DateTime data) {
  String dois(int valor) => valor.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} '
      '${dois(data.hour)}:${dois(data.minute)}';
}
