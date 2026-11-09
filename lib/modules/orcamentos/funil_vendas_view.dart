import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import 'orcamentos_lista_controller.dart';

class FunilVendasView extends GetView<OrcamentosListaController> {
  const FunilVendasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Funil de vendas'),
        centerTitle: false,
      ),
      body: Obx(() {
        final registros = controller.resumos;
        final pendentes = registros
            .where((r) => r.orcamento.status == 'pendente')
            .toList();
        final enviados = registros
            .where((r) => r.orcamento.status.toLowerCase() == 'enviado')
            .toList();
        final aprovados = registros
            .where((r) => r.orcamento.status.toLowerCase() == 'aprovado')
            .toList();
        final perdidos = registros
            .where((r) =>
                r.orcamento.status.toLowerCase() == 'perdido' ||
                r.orcamento.status.toLowerCase() == 'recusado')
            .toList();
        final total = pendentes.length + enviados.length +
            aprovados.length + perdidos.length;
        final taxa = total == 0 ? 0.0 : aprovados.length / total;
        final totalPendente = pendentes.fold<int>(
            0, (soma, resumo) => soma + resumo.totalCentavos);
        final totalEnviado = enviados.fold<int>(
            0, (soma, resumo) => soma + resumo.totalCentavos);
        final totalAprovado = aprovados.fold<int>(
            0, (soma, resumo) => soma + resumo.totalCentavos);
        final totalPerdido = perdidos.fold<int>(
            0, (soma, resumo) => soma + resumo.totalCentavos);

        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.ouro,
              strokeWidth: 2,
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _PainelVisaoGeral(
              quantidade: total,
              taxaAprovacao: taxa,
              valorAprovado: totalAprovado,
            ),
            const SizedBox(height: 20),
            Text(
              'Etapas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.texto,
                  ),
            ),
            const SizedBox(height: 12),
            _EtapaFunil(
              titulo: 'Em negociação',
              descricao: 'Orçamentos aguardando retorno ou decisão.',
              quantidade: pendentes.length,
              valorCentavos: totalPendente,
              proporcao: total == 0 ? 0.0 : pendentes.length / total,
              cor: AppColors.pendente,
              icone: Icons.hourglass_bottom_rounded,
              aoTocar: () {
                controller.definirFiltro('pendente');
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            _EtapaFunil(
              titulo: 'Enviados',
              descricao: 'Propostas encaminhadas aos clientes.',
              quantidade: enviados.length,
              valorCentavos: totalEnviado,
              proporcao: total == 0 ? 0.0 : enviados.length / total,
              cor: AppColors.roseGold,
              icone: Icons.send_rounded,
              aoTocar: () {
                controller.definirFiltro('enviado');
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            _EtapaFunil(
              titulo: 'Aprovados',
              descricao: 'Eventos confirmados pelos clientes.',
              quantidade: aprovados.length,
              valorCentavos: totalAprovado,
              proporcao: total == 0 ? 0.0 : aprovados.length / total,
              cor: AppColors.aprovado,
              icone: Icons.check_circle_outline_rounded,
              aoTocar: () {
                controller.definirFiltro('aprovado');
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            _EtapaFunil(
              titulo: 'Perdidos',
              descricao: 'Orçamentos que não avançaram para aprovação.',
              quantidade: perdidos.length,
              valorCentavos: totalPerdido,
              proporcao: total == 0 ? 0.0 : perdidos.length / total,
              cor: AppColors.terracota,
              icone: Icons.close_rounded,
              aoTocar: () {
                controller.definirFiltro('perdido');
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                controller.definirFiltro('todos');
                Get.back();
              },
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Ver todos os orçamentos'),
              style: TextButton.styleFrom(foregroundColor: AppColors.roseGold),
            ),
            const SizedBox(height: 10),
            Text(
              'O funil acompanha propostas pendentes, enviadas, aprovadas e perdidas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.texto.withValues(alpha: 0.55),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PainelVisaoGeral extends StatelessWidget {
  const _PainelVisaoGeral({
    required this.quantidade,
    required this.taxaAprovacao,
    required this.valorAprovado,
  });

  final int quantidade;
  final double taxaAprovacao;
  final int valorAprovado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.superficie, AppColors.champagne],
        ),
        borderRadius: BorderRadius.circular(24),
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
                  color: AppColors.roseGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  color: AppColors.roseGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Visão geral',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.texto,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '$quantidade ${quantidade == 1 ? 'orçamento' : 'orçamentos'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.texto.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taxa de aprovação',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.texto.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(taxaAprovacao * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Valor aprovado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.texto.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatarMoeda(valorAprovado),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: taxaAprovacao,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.aprovado),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Percentual de aprovados entre todos os orçamentos do funil.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.texto.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _EtapaFunil extends StatelessWidget {
  const _EtapaFunil({
    required this.titulo,
    required this.descricao,
    required this.quantidade,
    required this.valorCentavos,
    required this.proporcao,
    required this.cor,
    required this.icone,
    required this.aoTocar,
  });

  final String titulo;
  final String descricao;
  final int quantidade;
  final int valorCentavos;
  final double proporcao;
  final Color cor;
  final IconData icone;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.superficie,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.sombraSutil,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icone, color: cor, size: 21),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                  ),
                  Text(
                    '$quantidade ${quantidade == 1 ? 'orçamento' : 'orçamentos'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.texto.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.texto.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatarMoeda(valorCentavos),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                  Text(
                    '${(proporcao * 100).round()}% do funil',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.texto.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: proporcao,
                  minHeight: 5,
                  backgroundColor: cor.withValues(alpha: 0.13),
                  valueColor: AlwaysStoppedAnimation<Color>(cor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
