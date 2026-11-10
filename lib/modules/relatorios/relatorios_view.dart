import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'relatorios_controller.dart';
import 'relatorios_export_service.dart';

class RelatoriosView extends GetView<RelatoriosController> {
  const RelatoriosView({super.key});

  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final NumberFormat _percentual = NumberFormat.percentPattern('pt_BR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          Obx(() {
            final ocupada = controller.exportando.value;
            return PopupMenuButton<FormatoRelatorioExportacao>(
              enabled: controller.orcamentos.isNotEmpty && !ocupada,
              tooltip: 'Exportar relatório',
              icon: ocupada
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.roseGold,
                      ),
                    )
                  : const Icon(Icons.ios_share_rounded),
              onSelected: (formato) => _exportar(formato),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: FormatoRelatorioExportacao.pdf,
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined),
                      SizedBox(width: 10),
                      Text('Compartilhar PDF'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: FormatoRelatorioExportacao.csv,
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined),
                      SizedBox(width: 10),
                      Text('Compartilhar CSV'),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.ouro),
          );
        }
        if (controller.orcamentos.isEmpty) {
          return const _EstadoVazio();
        }
        if (controller.orcamentosFiltrados.isEmpty) {
          return _EstadoVazio(
            periodo: controller.periodoLabel,
            onLimpar: controller.limparPeriodo,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Visão geral',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Indicadores de ${controller.periodoLabel}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.68),
                  ),
            ),
            const SizedBox(height: 14),
            _SeletorPeriodo(controller: controller),
            const SizedBox(height: 20),
            _IndicadorPrincipal(
              quantidade: controller.quantidadeTotal,
              valor: _formatarMoeda(controller.valorTotalCentavos),
            ),
            const SizedBox(height: 14),
            _ConversaoCard(
              taxa: _percentual.format(controller.taxaConversao),
              aprovados: controller.quantidadeAprovados,
              concluidos: controller.quantidadeConcluida,
            ),
            const SizedBox(height: 26),
            Text('Orçamentos por etapa',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(
              'Quantidade e valor total em cada status.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.68),
                  ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.48,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _EtapaCard(
                  titulo: 'Aprovados',
                  quantidade: controller.quantidadeAprovados,
                  valor: _formatarMoeda(controller.valorAprovadoCentavos),
                  cor: AppColors.aprovado,
                  icone: Icons.check_circle_outline_rounded,
                ),
                _EtapaCard(
                  titulo: 'Enviados',
                  quantidade: controller.quantidadeEnviados,
                  valor: _formatarMoeda(controller.valorEnviadoCentavos),
                  cor: AppColors.ouro,
                  icone: Icons.outgoing_mail,
                ),
                _EtapaCard(
                  titulo: 'Pendentes',
                  quantidade: controller.quantidadePendentes,
                  valor: _formatarMoeda(controller.valorPendenteCentavos),
                  cor: AppColors.pendente,
                  icone: Icons.hourglass_empty_rounded,
                ),
                _EtapaCard(
                  titulo: 'Perdidos',
                  quantidade: controller.quantidadePerdidos,
                  valor: _formatarMoeda(controller.valorPerdidoCentavos),
                  cor: AppColors.terracota,
                  icone: Icons.cancel_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 26),
            Text('Clientes em destaque',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(
              'Maiores valores aprovados em ${controller.periodoLabel}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.68),
                  ),
            ),
            const SizedBox(height: 12),
            if (controller.principaisClientes.isEmpty)
              const _SemClientesAprovados()
            else
              ...controller.principaisClientes.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ClienteDestaqueCard(
                    posicao: entry.key + 1,
                    cliente: entry.value,
                    valor: _formatarMoeda(entry.value.valorCentavos),
                  ),
                );
              }),
            const SizedBox(height: 8),
            Text(
              'A conversão considera apenas orçamentos concluídos: aprovados '
              'e perdidos/recusados. Os valores são totais dos orçamentos, '
              'não representam pagamentos recebidos.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.62),
                    height: 1.45,
                  ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _exportar(FormatoRelatorioExportacao formato) async {
    if (controller.exportando.value) return;
    controller.exportando.value = true;
    try {
      final service = RelatoriosExportService();
      if (formato == FormatoRelatorioExportacao.pdf) {
        await service.compartilharPdf(controller);
      } else {
        await service.compartilharCsv(controller);
      }
      Get.snackbar(
        'Relatório preparado',
        'Escolha um aplicativo para compartilhar ou salvar o arquivo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Não foi possível exportar',
        'Tente novamente. Se o problema continuar, feche e reabra os relatórios.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      controller.exportando.value = false;
    }
  }

  static String _formatarMoeda(int centavos) =>
      _moeda.format(centavos / 100);
}

class _SeletorPeriodo extends StatelessWidget {
  const _SeletorPeriodo({required this.controller});

  final RelatoriosController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: AppColors.roseGold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Período analisado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.texto.withValues(alpha: 0.64),
                        )),
                Text(controller.periodoLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
          ),
          PopupMenuButton<PeriodoRelatorio>(
            tooltip: 'Selecionar período',
            icon: const Icon(Icons.tune_rounded, color: AppColors.texto),
            onSelected: (periodo) async {
              if (periodo != PeriodoRelatorio.personalizado) {
                controller.definirPeriodo(periodo);
                return;
              }
              final hoje = DateTime.now();
              final intervalo = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: DateTimeRange(
                  start: DateTime(hoje.year, hoje.month, 1),
                  end: hoje,
                ),
                helpText: 'Selecione o período dos eventos',
                saveText: 'Aplicar período',
              );
              if (intervalo != null) {
                controller.definirPeriodo(
                  PeriodoRelatorio.personalizado,
                  inicio: intervalo.start,
                  fim: intervalo.end,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: PeriodoRelatorio.todos,
                child: Text('Todo o período'),
              ),
              PopupMenuItem(
                value: PeriodoRelatorio.mesAtual,
                child: Text('Este mês'),
              ),
              PopupMenuItem(
                value: PeriodoRelatorio.ultimos30Dias,
                child: Text('Últimos 30 dias'),
              ),
              PopupMenuItem(
                value: PeriodoRelatorio.anoAtual,
                child: Text('Este ano'),
              ),
              PopupMenuItem(
                value: PeriodoRelatorio.personalizado,
                child: Text('Escolher datas...'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicadorPrincipal extends StatelessWidget {
  const _IndicadorPrincipal({required this.quantidade, required this.valor});

  final int quantidade;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B4C5C), Color(0xFF253543)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.champagne),
            const SizedBox(width: 9),
            Text('Total em orçamentos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
          ]),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$quantidade ${quantidade == 1 ? 'orçamento cadastrado' : 'orçamentos cadastrados'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
        ],
      ),
    );
  }
}

class _ConversaoCard extends StatelessWidget {
  const _ConversaoCard({
    required this.taxa,
    required this.aprovados,
    required this.concluidos,
  });

  final String taxa;
  final int aprovados;
  final int concluidos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.champagne,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: AppColors.roseGold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conversão final',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 4),
                Text('$aprovados aprovados de $concluidos concluídos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.texto.withValues(alpha: 0.65),
                        )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            taxa,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.roseGold,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ClienteDestaqueCard extends StatelessWidget {
  const _ClienteDestaqueCard({
    required this.posicao,
    required this.cliente,
    required this.valor,
  });

  final int posicao;
  final ClienteRelatorioResumo cliente;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: posicao == 1 ? AppColors.champagne : AppColors.fundo,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$posicao',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: posicao == 1 ? AppColors.roseGold : AppColors.texto,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${cliente.quantidadeOrcamentos} ${cliente.quantidadeOrcamentos == 1 ? 'orçamento aprovado' : 'orçamentos aprovados'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.texto.withValues(alpha: 0.65),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.texto,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemClientesAprovados extends StatelessWidget {
  const _SemClientesAprovados();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_outlined, color: AppColors.roseGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ainda não há orçamentos aprovados neste período.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.72),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EtapaCard extends StatelessWidget {
  const _EtapaCard({
    required this.titulo,
    required this.quantidade,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  final String titulo;
  final int quantidade;
  final String valor;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icone, color: cor, size: 19),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ]),
          const Spacer(),
          Text(
            '$quantidade ${quantidade == 1 ? 'orçamento' : 'orçamentos'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.texto.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.texto,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({this.periodo, this.onLimpar});

  final String? periodo;
  final VoidCallback? onLimpar;

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
              decoration: BoxDecoration(
                color: AppColors.champagne,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.query_stats_rounded,
                  size: 36, color: AppColors.roseGold),
            ),
            const SizedBox(height: 18),
            Text(
              onLimpar == null ? 'Ainda não há dados para exibir' : 'Nenhum orçamento neste período',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              onLimpar == null
                  ? 'Cadastre orçamentos para acompanhar os valores e a conversão por etapa.'
                  : 'Não encontramos orçamentos com evento em $periodo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.texto.withValues(alpha: 0.68),
                  ),
            ),
            if (onLimpar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onLimpar,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Ver todo o período'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
