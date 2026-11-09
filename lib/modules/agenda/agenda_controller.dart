import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';

class AgendaController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final eventos = <Evento>[].obs;
  final diaSelecionado = DateUtils.dateOnly(DateTime.now()).obs;
  final carregando = true.obs;

  StreamSubscription<List<Evento>>? _subscription;

  @override
  void onInit() {
    super.onInit();

    _subscription = (db.select(db.eventos)
          ..orderBy([
            (evento) => OrderingTerm.asc(evento.inicio),
          ]))
        .watch()
        .listen((lista) {
      eventos.assignAll(lista);
      carregando.value = false;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  List<Evento> eventosDoDia(DateTime dia) {
    final data = DateUtils.dateOnly(dia);

    return eventos.where((evento) {
      final inicio = DateUtils.dateOnly(evento.inicio);
      final fim = DateUtils.dateOnly(evento.fim);

      return !data.isBefore(inicio) && !data.isAfter(fim);
    }).toList();
  }

  List<Evento> get eventosSelecionados =>
      eventosDoDia(diaSelecionado.value);

  void selecionarDia(DateTime dia) {
    diaSelecionado.value = DateUtils.dateOnly(dia);
  }

  Future<void> salvarEvento({
    required String titulo,
    required DateTime inicio,
    required DateTime fim,
    String? local,
    int? orcamentoId,
  }) async {
    if (titulo.trim().isEmpty) {
      throw Exception('Informe o título do evento.');
    }

    if (fim.isBefore(inicio)) {
      throw Exception(
        'A data final não pode ser anterior à data inicial.',
      );
    }

    await db.into(db.eventos).insert(
          EventosCompanion.insert(
            titulo: titulo.trim(),
            inicio: inicio,
            fim: fim,
            local: Value(_valorOuNulo(local)),
            orcamentoId: Value(orcamentoId),
          ),
        );
  }

  Future<void> excluirEvento(Evento evento) async {
    await (db.delete(db.eventos)..where((item) => item.id.equals(evento.id)))
        .go();
  }

  Future<void> abrirFormulario({Evento? evento}) async {
    final tituloController =
        TextEditingController(text: evento?.titulo ?? '');
    final localController =
        TextEditingController(text: evento?.local ?? '');

    DateTime inicio = evento?.inicio ?? DateTime.now();
    DateTime fim = evento?.fim ?? DateTime.now().add(
          const Duration(hours: 2),
        );

    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              evento == null ? 'Novo evento' : 'Editar evento',
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tituloController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Título do evento',
                        prefixIcon: Icon(Icons.celebration_outlined),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o título';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: localController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Local',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DataHoraField(
                      label: 'Início',
                      data: inicio,
                      onChanged: (valor) {
                        setState(() => inicio = valor);
                      },
                    ),
                    const SizedBox(height: 10),
                    _DataHoraField(
                      label: 'Fim',
                      data: fim,
                      onChanged: (valor) {
                        setState(() => fim = valor);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  try {
                    if (evento == null) {
                      await salvarEvento(
                        titulo: tituloController.text,
                        local: localController.text,
                        inicio: inicio,
                        fim: fim,
                      );
                    } else {
                      await atualizarEvento(
                        evento: evento,
                        titulo: tituloController.text,
                        local: localController.text,
                        inicio: inicio,
                        fim: fim,
                      );
                    }

                    Get.back();

                    Get.snackbar(
                      'Sucesso',
                      evento == null
                          ? 'Evento adicionado à agenda.'
                          : 'Evento atualizado com sucesso.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Não foi possível salvar',
                      e.toString().replaceFirst('Exception: ', ''),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    tituloController.dispose();
    localController.dispose();
  }

  Future<void> atualizarEvento({
    required Evento evento,
    required String titulo,
    required String local,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    if (fim.isBefore(inicio)) {
      throw Exception(
        'A data final não pode ser anterior à data inicial.',
      );
    }

    await (db.update(db.eventos)..where((item) => item.id.equals(evento.id)))
        .write(
      EventosCompanion(
        titulo: Value(titulo.trim()),
        local: Value(_valorOuNulo(local)),
        inicio: Value(inicio),
        fim: Value(fim),
      ),
    );
  }

  String? _valorOuNulo(String? valor) {
    final valorLimpo = valor?.trim();

    if (valorLimpo == null || valorLimpo.isEmpty) {
      return null;
    }

    return valorLimpo;
  }
}

class _DataHoraField extends StatelessWidget {
  const _DataHoraField({
    required this.label,
    required this.data,
    required this.onChanged,
  });

  final String label;
  final DateTime data;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final novaData = await showDatePicker(
          context: context,
          initialDate: data,
          firstDate: DateTime(2020),
          lastDate: DateTime(2200),
          locale: const Locale('pt', 'BR'),
        );

        if (novaData == null || !context.mounted) {
          return;
        }

        final novoHorario = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(data),
        );

        if (novoHorario == null) {
          return;
        }

        onChanged(
          DateTime(
            novaData.year,
            novaData.month,
            novaData.day,
            novoHorario.hour,
            novoHorario.minute,
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          _formatarDataHora(data),
          style: const TextStyle(
            color: AppColors.texto,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }
}