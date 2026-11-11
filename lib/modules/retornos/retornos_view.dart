import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'retornos_controller.dart';

class RetornosView extends GetView<RetornosController> {
  const RetornosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Retornos'),
        backgroundColor: AppColors.fundo,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Atualizar retornos',
            onPressed: () => controller.carregar(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.carregando.value && controller.retornos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final lista = controller.retornosVisiveis;
        return RefreshIndicator(
          onRefresh: () => controller.carregar(),
          color: AppColors.roseGold,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _ResumoRetornos(controller: controller),
              const SizedBox(height: 18),
              const Text(
                'Organize seus próximos contatos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 10),
              _FiltrosRetorno(controller: controller),
              const SizedBox(height: 14),
              if (controller.erro.value != null && lista.isEmpty)
                _EstadoVazio(
                  icone: Icons.wifi_off_outlined,
                  titulo: 'Não foi possível carregar',
                  descricao: controller.erro.value!,
                  acao: TextButton.icon(
                    onPressed: () => controller.carregar(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                )
              else if (lista.isEmpty)
                _EstadoVazio(
                  icone: controller.retornos.isEmpty
                      ? Icons.notifications_none_rounded
                      : Icons.check_circle_outline_rounded,
                  titulo: controller.retornos.isEmpty
                      ? 'Nenhum retorno agendado'
                      : 'Tudo em dia por aqui',
                  descricao: controller.retornos.isEmpty
                      ? 'Ao registrar um contato, você pode definir uma data para retomar a conversa.'
                      : 'Não há retornos nesta categoria. Escolha outro filtro para conferir a lista.',
                )
              else
                for (final retorno in lista)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _RetornoCard(
                      retorno: retorno,
                      controller: controller,
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}

class _ResumoRetornos extends StatelessWidget {
  const _ResumoRetornos({required this.controller});

  final RetornosController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ContagemRetorno(
              titulo: 'Atrasados',
              valor: controller.quantidadeAtrasados,
              cor: AppColors.terracota,
              icone: Icons.notification_important_outlined,
            ),
          ),
          _divisorResumo(),
          Expanded(
            child: _ContagemRetorno(
              titulo: 'Hoje',
              valor: controller.quantidadeHoje,
              cor: AppColors.roseGold,
              icone: Icons.today_rounded,
            ),
          ),
          _divisorResumo(),
          Expanded(
            child: _ContagemRetorno(
              titulo: 'Próximos',
              valor: controller.quantidadeProximos,
              cor: AppColors.sage,
              icone: Icons.notifications_active_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _divisorResumo() => Container(
      width: 1,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: AppColors.texto.withValues(alpha: 0.1),
    );

class _ContagemRetorno extends StatelessWidget {
  const _ContagemRetorno({
    required this.titulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  final String titulo;
  final int valor;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, color: cor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          '$valor',
          style: TextStyle(
            fontSize: 19,
            height: 1,
            fontWeight: FontWeight.w800,
            color: cor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.texto,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FiltrosRetorno extends StatelessWidget {
  const _FiltrosRetorno({required this.controller});

  final RetornosController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _filtro('Todos', FiltroRetorno.todos),
            _filtro('Atrasados', FiltroRetorno.atrasados),
            _filtro('Hoje', FiltroRetorno.hoje),
            _filtro('Próximos', FiltroRetorno.proximos),
          ],
        ));
  }

  Widget _filtro(String texto, FiltroRetorno valor) {
    final selecionado = controller.filtro.value == valor;
    return FilterChip(
      label: Text(texto),
      selected: selecionado,
      onSelected: (_) => controller.selecionarFiltro(valor),
      showCheckmark: false,
      selectedColor: AppColors.champagne,
      backgroundColor: AppColors.superficie,
      side: BorderSide(
        color: selecionado
            ? AppColors.roseGold.withValues(alpha: 0.42)
            : AppColors.texto.withValues(alpha: 0.10),
      ),
      labelStyle: TextStyle(
        color: selecionado ? AppColors.roseGold : AppColors.texto,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RetornoCard extends StatelessWidget {
  const _RetornoCard({
    required this.retorno,
    required this.controller,
  });

  final RetornoOrcamento retorno;
  final RetornosController controller;

  Future<void> _reagendar(BuildContext context) async {
    final agora = DateTime.now();
    final inicioDia = DateTime(agora.year, agora.month, agora.day);
    final dataInicial = retorno.quando.isBefore(inicioDia)
        ? inicioDia
        : retorno.quando;
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: inicioDia,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Escolha a nova data do retorno',
    );
    if (data == null || !context.mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(retorno.quando),
      helpText: 'Escolha o novo horário',
    );
    if (hora == null || !context.mounted) return;

    final novoRetorno = DateTime(
      data.year,
      data.month,
      data.day,
      hora.hour,
      hora.minute,
    );
    await controller.reagendarRetorno(retorno, novoRetorno);
  }

  @override
  Widget build(BuildContext context) {
    final cor = retorno.atrasado
        ? AppColors.terracota
        : retorno.hoje
            ? AppColors.roseGold
            : AppColors.sage;
    final etiqueta = retorno.atrasado
        ? 'Atrasado'
        : retorno.hoje
            ? 'Hoje'
            : 'Agendado';
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => controller.abrirOrcamento(retorno),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cor.withValues(alpha: 0.22)),
            boxShadow: AppTheme.sombraSutil,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          retorno.cliente,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.texto,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          retorno.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.texto.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      etiqueta,
                      style: TextStyle(
                        color: cor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                retorno.resumo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.texto.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: cor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.formatarDataHora(retorno.quando),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cor,
                      ),
                    ),
                  ),
                  Text(
                    retorno.canal,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.texto.withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: AppColors.texto,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _reagendar(context),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Reagendar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.roseGold,
                      side: BorderSide(
                        color: AppColors.roseGold.withValues(alpha: 0.42),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => controller.concluirRetorno(retorno),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Concluir'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppColors.sage,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        children: [
          Icon(icone, size: 34, color: AppColors.roseGold),
          const SizedBox(height: 10),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.texto.withValues(alpha: 0.65),
            ),
          ),
          if (acao != null) ...[
            const SizedBox(height: 8),
            acao!,
          ],
        ],
      ),
    );
  }
}
