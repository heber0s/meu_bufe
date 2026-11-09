import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/database/app_database.dart';
import 'agenda_controller.dart';
import 'evento_checklist_controller.dart';
import 'evento_checklist_sheet.dart';

class AgendaView extends GetView<AgendaController> {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.abrirFormulario,
          backgroundColor: AppColors.ouro,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Novo evento'),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Todos os momentos importantes em um só lugar.',
                      style: TextStyle(
                        color: AppColors.texto.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _Calendario(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                child: Obx(
                  () => Text(
                    DateFormat(
                      "EEEE, dd 'de' MMMM",
                      'pt_BR',
                    ).format(controller.diaSelecionado.value),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
            Obx(() {
              final eventos = controller.eventosSelecionados;

              if (controller.carregando.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.ouro,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (eventos.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EstadoVazioAgenda(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
                sliver: SliverList.separated(
                  itemCount: eventos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _EventoCard(evento: eventos[index]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Calendario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgendaController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.sombraSutil,
        ),
        padding: const EdgeInsets.all(8),
        child: TableCalendar<Evento>(
          // Mantem o calendario reativo ao carregamento/alteracao dos eventos.
          // Sem esta dependencia, os marcadores so atualizam ao selecionar um dia.
          key: ValueKey(controller.eventos.length),
          locale: 'pt_BR',
          firstDay: DateTime(2020),
          lastDay: DateTime(2200),
          focusedDay: controller.diaSelecionado.value,
          selectedDayPredicate: (day) => isSameDay(
            controller.diaSelecionado.value,
            day,
          ),
          eventLoader: controller.eventosDoDia,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mês',
          },
          onDaySelected: (selectedDay, focusedDay) {
            controller.selecionarDia(selectedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: AppColors.champagne.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.texto,
              fontWeight: FontWeight.w700,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.roseGold,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.ouro,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.roseGold,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.roseGold,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  const _EventoCard({required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgendaController>();

    return PressableScale(
      onTap: () => controller.abrirFormulario(evento: evento),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.roseGold,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: AppColors.roseGold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_hora(evento.inicio)} - ${_hora(evento.fim)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.texto.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                  if (evento.local != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.roseGold,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            evento.local!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.texto.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) async {
                if (opcao == 'editar') {
                  controller.abrirFormulario(evento: evento);
                }

                if (opcao == 'checklist') {
                  _abrirChecklist(evento);
                }

                if (opcao == 'excluir') {
                  await controller.excluirEvento(evento);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'checklist',
                  child: Row(
                    children: [
                      Icon(Icons.checklist_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Checklist'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirChecklist(Evento evento) {
    final tag = 'evento-checklist-${evento.id}';
    final checklistController = Get.put(
      EventoChecklistController(eventoId: evento.id),
      tag: tag,
    );

    Get.bottomSheet<void>(
      EventoChecklistSheet(
        evento: evento,
        controller: checklistController,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    ).whenComplete(() {
      if (Get.isRegistered<EventoChecklistController>(tag: tag)) {
        Get.delete<EventoChecklistController>(tag: tag);
      }
    });
  }

  String _hora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }
}

class _EstadoVazioAgenda extends StatelessWidget {
  const _EstadoVazioAgenda();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 130),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppColors.champagne,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 38,
                color: AppColors.roseGold,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Nenhum evento neste dia',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Sua agenda está livre por enquanto.',
              style: TextStyle(
                color: AppColors.texto.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
