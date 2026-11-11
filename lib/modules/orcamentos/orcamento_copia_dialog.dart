import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';

class OrcamentoCopiaDados {
  const OrcamentoCopiaDados({
    required this.titulo,
    required this.dataEvento,
    required this.local,
    required this.convidados,
  });

  final String titulo;
  final DateTime dataEvento;
  final String local;
  final int convidados;
}

class OrcamentoCopiaDialog extends StatefulWidget {
  const OrcamentoCopiaDialog({
    super.key,
    required this.orcamento,
  });

  final Orcamento orcamento;

  @override
  State<OrcamentoCopiaDialog> createState() => _OrcamentoCopiaDialogState();
}

class _OrcamentoCopiaDialogState extends State<OrcamentoCopiaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl = TextEditingController(
    text: 'Cópia de ${widget.orcamento.titulo}',
  );
  late final TextEditingController _localCtrl = TextEditingController(
    text: widget.orcamento.local ?? '',
  );
  late final TextEditingController _convidadosCtrl = TextEditingController(
    text: '${widget.orcamento.convidados}',
  );
  late DateTime _dataEvento = widget.orcamento.dataEvento;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _localCtrl.dispose();
    _convidadosCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataEvento,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      locale: const Locale('pt', 'BR'),
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataEvento),
    );
    if (hora == null || !mounted) return;

    setState(() {
      _dataEvento = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  String _formatarDataHora(DateTime data) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} às '
        '${dois(data.hour)}:${dois(data.minute)}';
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      OrcamentoCopiaDados(
        titulo: _tituloCtrl.text.trim(),
        dataEvento: _dataEvento,
        local: _localCtrl.text.trim(),
        convidados: int.parse(_convidadosCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.superficie,
      title: const Text('Dados do novo evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do evento',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe o nome do evento.'
                    : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _escolherDataHora,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data e horário',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(_formatarDataHora(_dataEvento)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _localCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Local',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _convidadosCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número de convidados',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                validator: (valor) {
                  final quantidade = int.tryParse(valor?.trim() ?? '');
                  if (quantidade == null || quantidade < 0) {
                    return 'Informe uma quantidade válida.';
                  }
                  return null;
                },
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
        FilledButton.icon(
          onPressed: _confirmar,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Criar cópia'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.ouro),
        ),
      ],
    );
  }
}
