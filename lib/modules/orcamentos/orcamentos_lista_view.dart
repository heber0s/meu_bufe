import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/status_chip.dart';
import '../../routes/app_routes.dart';
import 'orcamentos_lista_controller.dart';

class OrcamentosListaView extends GetView<OrcamentosListaController> {
  const OrcamentosListaView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      // AnimationLimiter: as animações escalonadas rodam só na primeira
      // renderização, e não a cada rolagem.
      child: AnimationLimiter(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Cabecalho(controller: controller)),
            SliverToBoxAdapter(child: _Busca(controller: controller)),
            SliverToBoxAdapter(child: _Filtros(controller: controller)),
            // Controller atua aqui: lista filtrada/pesquisada reage via Obx
            Obx(() {
              if (controller.carregando.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.ouro, strokeWidth: 2),
                  ),
                );
              }

              final lista = controller.filtrados;
              if (lista.isEmpty) return const _EstadoVazio();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 450),
                    child: SlideAnimation(
                      verticalOffset: 40,
                      child: FadeInAnimation(
                        child: _OrcamentoCard(resumo: lista[i]),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.controller});
  final OrcamentosListaController controller;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orçamentos', style: tema.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Seus eventos, com todo o requinte.',
            style: tema.bodyMedium?.copyWith(
                color: AppColors.texto.withValues(alpha: 0.55), letterSpacing: 0.2),
          ),
          const SizedBox(height: 20),
          // Totais atualizam em tempo real conforme os orçamentos mudam
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _CardResumo(
                      rotulo: 'Aprovados',
                      valor: controller.totalAprovadoCentavos,
                      cor: AppColors.aprovado,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardResumo(
                      rotulo: 'Em negociação',
                      valor: controller.totalPendenteCentavos,
                      cor: AppColors.pendente,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _CardResumo extends StatelessWidget {
  const _CardResumo(
      {required this.rotulo, required this.valor, required this.cor});

  final String rotulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(rotulo,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.texto.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: FittedBox(
              key: ValueKey(valor),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatarMoeda(valor),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Busca extends StatelessWidget {
  const _Busca({required this.controller});
  final OrcamentosListaController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: TextField(
          onChanged: (v) => controller.busca.value = v,
          decoration: InputDecoration(
            hintText: 'Buscar por evento ou cliente',
            hintStyle: TextStyle(
                fontSize: 14, color: AppColors.texto.withValues(alpha: 0.4)),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.roseGold),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.controller});
  final OrcamentosListaController controller;

  static const _opcoes = {
    'todos': 'Todos',
    'pendente': 'Pendentes',
    'aprovado': 'Aprovados',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            children: _opcoes.entries.map((e) {
              final ativo = controller.filtro.value == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.definirFiltro(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ativo ? AppColors.ouro : AppColors.superficie,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: ativo ? null : AppTheme.sombraSutil,
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ativo ? Colors.white : AppColors.texto,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _OrcamentoCard extends StatelessWidget {
  const _OrcamentoCard({required this.resumo});
  final OrcamentoResumo resumo;

  @override
  Widget build(BuildContext context) {
    final o = resumo.orcamento;
    final tema = Theme.of(context).textTheme;

    return PressableScale(
      onTap: () => Get.toNamed(Routes.detalhe(o.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Row(
          children: [
            // Hero: a mesma tag será usada na SliverAppBar do detalhe
            Hero(
              tag: 'orcamento-${o.id}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 58,
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.champagne,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(diaDoEvento(o.dataEvento),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.texto)),
                      Text(mesDoEvento(o.dataEvento),
                          style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.roseGold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(resumo.cliente.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.bodySmall?.copyWith(
                          color: AppColors.texto.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 15,
                          color: AppColors.texto.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('${o.convidados} convidados',
                          style: tema.bodySmall?.copyWith(
                              color: AppColors.texto.withValues(alpha: 0.6))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatarMoeda(resumo.totalCentavos),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                StatusChip(status: o.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                  color: AppColors.champagne, shape: BoxShape.circle),
              child: const Icon(Icons.celebration_outlined,
                  size: 38, color: AppColors.roseGold),
            ),
            const SizedBox(height: 20),
            Text('Nenhum orçamento por aqui',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Toque em "Novo orçamento" para começar.',
                style: TextStyle(color: AppColors.texto.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}