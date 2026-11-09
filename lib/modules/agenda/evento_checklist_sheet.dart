import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import 'evento_checklist_controller.dart';

class EventoChecklistSheet extends StatefulWidget {
  const EventoChecklistSheet({
    super.key,
    required this.evento,
    required this.controller,
  });

  final Evento evento;
  final EventoChecklistController controller;

  @override
  State<EventoChecklistSheet> createState() => _EventoChecklistSheetState();
}

class _EventoChecklistSheetState extends State<EventoChecklistSheet> {
  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.sizeOf(context).height * 0.84;

    return Container(
      height: altura,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.texto.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.champagne,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: AppColors.roseGold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checklist do evento',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.evento.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.texto.withValues(alpha: 0.62),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Obx(() {
                final total = widget.controller.tarefas.length;
                final concluidas = widget.controller.concluidas;
                final progresso = total == 0 ? 0.0 : concluidas / total;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppTheme.sombraSutil,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progresso da organização',
                            style: TextStyle(
                              color: AppColors.texto,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$concluidas de $total concluídas',
                            style: const TextStyle(
                              color: AppColors.roseGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progresso,
                          minHeight: 7,
                          backgroundColor: AppColors.champagne,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.roseGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _abrirFormularioTarefa(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar tarefa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ouro,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (widget.controller.carregando.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.ouro,
                      strokeWidth: 2,
                    ),
                  );
                }

                if (widget.controller.erro.value.isNotEmpty) {
                  return _MensagemEstado(
                    icone: Icons.error_outline_rounded,
                    mensagem: 'Não foi possível carregar as tarefas.',
                    detalhe: widget.controller.erro.value,
                    acao: TextButton(
                      onPressed: widget.controller.carregar,
                      child: const Text('Tentar novamente'),
                    ),
                  );
                }

                if (widget.controller.tarefas.isEmpty) {
                  return const _MensagemEstado(
                    icone: Icons.task_alt_rounded,
                    mensagem: 'Nenhuma tarefa por enquanto',
                    detalhe: 'Adicione os próximos passos para este evento.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
                  itemCount: widget.controller.tarefas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final tarefa = widget.controller.tarefas[index];
                    return _TarefaCard(
                      tarefa: tarefa,
                      controller: widget.controller,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirFormularioTarefa(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _NovaTarefaDialog(controller: widget.controller),
    );
  }
}

class _NovaTarefaDialog extends StatefulWidget {
  const _NovaTarefaDialog({required this.controller});

  final EventoChecklistController controller;

  @override
  State<_NovaTarefaDialog> createState() => _NovaTarefaDialogState();
}

class _NovaTarefaDialogState extends State<_NovaTarefaDialog> {
  final _tituloController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _prazo;
  bool _enviando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  Future<void> _selecionarPrazo() async {
    final selecionado = await showDatePicker(
      context: context,
      initialDate: _prazo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2200),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionado == null || !mounted) return;

    setState(() {
      _prazo = DateTime(
        selecionado.year,
        selecionado.month,
        selecionado.day,
      );
    });
  }

  Future<void> _salvar() async {
    if (_enviando || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _enviando = true);

    try {
      await widget.controller.adicionar(
        titulo: _tituloController.text,
        responsavel: _responsavelController.text,
        prazo: _prazo,
      );

      if (mounted) Get.back<void>();
    } catch (e) {
      if (!mounted) return;

      setState(() => _enviando = false);
      Get.snackbar(
        'Não foi possível salvar',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova tarefa'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tarefa',
                  hintText: 'Ex.: Confirmar número de convidados',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe a tarefa'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _responsavelController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Responsável (opcional)',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _selecionarPrazo,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Prazo (opcional)',
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: _prazo == null
                        ? null
                        : IconButton(
                            tooltip: 'Remover prazo',
                            onPressed: () => setState(() => _prazo = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                  child: Text(
                    _prazo == null
                        ? 'Selecionar data'
                        : DateFormat('dd/MM/yyyy').format(_prazo!),
                    style: TextStyle(
                      color: _prazo == null
                          ? AppColors.texto.withValues(alpha: 0.5)
                          : AppColors.texto,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Get.back<void>(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _salvar,
          child: _enviando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }
}

class _TarefaCard extends StatelessWidget {
  const _TarefaCard({
    required this.tarefa,
    required this.controller,
  });

  final EventoChecklistTarefa tarefa;
  final EventoChecklistController controller;

  @override
  Widget build(BuildContext context) {
    final vencida = !tarefa.concluida &&
        tarefa.prazo != null &&
        DateUtils.dateOnly(tarefa.prazo!).isBefore(
          DateUtils.dateOnly(DateTime.now()),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox.adaptive(
            value: tarefa.concluida,
            activeColor: AppColors.roseGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (_) => _executar(
              () => controller.alternarConclusao(tarefa),
              'Não foi possível atualizar a tarefa.',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarefa.titulo,
                    style: TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w600,
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (tarefa.responsavel != null || tarefa.prazo != null) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        if (tarefa.responsavel != null)
                          _InfoTarefa(
                            icone: Icons.person_outline_rounded,
                            texto: tarefa.responsavel!,
                          ),
                        if (tarefa.prazo != null)
                          _InfoTarefa(
                            icone: Icons.event_outlined,
                            texto: DateFormat('dd/MM/yyyy').format(tarefa.prazo!),
                            cor: vencida ? const Color(0xFFB65345) : null,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Excluir tarefa',
            visualDensity: VisualDensity.compact,
            onPressed: () => _executar(
              () => controller.excluir(tarefa),
              'Não foi possível excluir a tarefa.',
            ),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.texto.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executar(Future<void> Function() acao, String erro) async {
    try {
      await acao();
    } catch (_) {
      Get.snackbar(
        'Ops',
        erro,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _InfoTarefa extends StatelessWidget {
  const _InfoTarefa({
    required this.icone,
    required this.texto,
    this.cor,
  });

  final IconData icone;
  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final corInfo = cor ?? AppColors.texto.withValues(alpha: 0.58);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: corInfo),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(fontSize: 12, color: corInfo),
        ),
      ],
    );
  }
}

class _MensagemEstado extends StatelessWidget {
  const _MensagemEstado({
    required this.icone,
    required this.mensagem,
    required this.detalhe,
    this.acao,
  });

  final IconData icone;
  final String mensagem;
  final String detalhe;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 38, color: AppColors.roseGold),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.texto,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              detalhe,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.texto.withValues(alpha: 0.56),
              ),
            ),
            ?acao,
          ],
        ),
      ),
    );
  }
}
