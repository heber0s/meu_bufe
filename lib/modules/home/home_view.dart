import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../agenda/agenda_view.dart';
import '../clientes/clientes_view.dart';
import '../orcamentos/orcamentos_lista_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          switch (controller.abaAtual.value) {
            case 1:
              return const Text('Agenda');
            case 2:
              return const Text('Clientes');
            default:
              return const Text('Orçamentos');
          }
        }),
        actions: [
          IconButton(
            tooltip: 'Mais recursos',
            onPressed: () => _abrirMenuRecursos(context),
            icon: const Icon(Icons.apps_rounded),
          ),
        ],
      ),
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.abaAtual.value,
          children: const [
            OrcamentosListaView(),
            AgendaView(),
            ClientesView(),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: controller.abaAtual.value == 0
              ? FloatingActionButton.extended(
                  key: const ValueKey('fab'),
                  heroTag: null,
                  onPressed: () => Get.toNamed(Routes.orcamentoForm),
                  backgroundColor: AppColors.ouro,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Novo orçamento'),
                )
              : const SizedBox.shrink(key: ValueKey('vazio')),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Obx(
            () => NavigationBar(
              height: 68,
              backgroundColor: AppColors.superficie,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.champagne,
              selectedIndex: controller.abaAtual.value,
              onDestinationSelected: controller.trocarAba,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.roseGold,
                  ),
                  label: 'Orçamentos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.roseGold,
                  ),
                  label: 'Agenda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(
                    Icons.people_alt_rounded,
                    color: AppColors.roseGold,
                  ),
                  label: 'Clientes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirMenuRecursos(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MenuRecursosSheet(),
    );
  }
}

class _MenuRecursosSheet extends StatelessWidget {
  const _MenuRecursosSheet();

  static const List<_GrupoRecursos> _grupos = [
    _GrupoRecursos(
      titulo: 'GESTÃO',
      recursos: [
        _RecursoHome(
          titulo: 'Relatórios',
          descricao: 'Indicadores e resultados',
          icone: Icons.bar_chart_rounded,
          rota: Routes.relatorios,
        ),
        _RecursoHome(
          titulo: 'Funil de vendas',
          descricao: 'Acompanhe suas oportunidades',
          icone: Icons.filter_alt_outlined,
          rota: Routes.funilVendas,
        ),
      ],
    ),
    _GrupoRecursos(
      titulo: 'SEU BUFÊ',
      recursos: [
        _RecursoHome(
          titulo: 'Catálogo',
          descricao: 'Produtos e opções do cardápio',
          icone: Icons.grid_view_rounded,
          rota: Routes.catalogo,
        ),
        _RecursoHome(
          titulo: 'Receitas',
          descricao: 'Consulte e organize receitas',
          icone: Icons.menu_book_outlined,
          rota: Routes.receitas,
        ),
        _RecursoHome(
          titulo: 'Serviços',
          descricao: 'Gerencie os serviços oferecidos',
          icone: Icons.room_service_outlined,
          rota: Routes.servicos,
        ),
      ],
    ),
    _GrupoRecursos(
      titulo: 'PREFERÊNCIAS',
      recursos: [
        _RecursoHome(
          titulo: 'Ajustes',
          descricao: 'Dados da empresa e configurações',
          icone: Icons.settings_outlined,
          rota: Routes.ajustes,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mais recursos',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tudo o que você precisa, organizado por área.',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF68727C),
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final grupo in _grupos) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                      child: Text(
                        grupo.titulo,
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF8A7B70),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF0ECE7)),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < grupo.recursos.length; i++) ...[
                            _RecursoTile(recurso: grupo.recursos[i]),
                            if (i < grupo.recursos.length - 1)
                              const Padding(
                                padding: EdgeInsets.only(left: 62),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F0EC),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecursoTile extends StatelessWidget {
  const _RecursoTile({required this.recurso});

  final _RecursoHome recurso;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).pop();
        Get.toNamed(recurso.rota);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.champagne,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(recurso.icone, color: AppColors.roseGold, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recurso.titulo,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recurso.descricao,
                    style: const TextStyle(
                      color: Color(0xFF77818A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9AA1A7),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrupoRecursos {
  const _GrupoRecursos({required this.titulo, required this.recursos});

  final String titulo;
  final List<_RecursoHome> recursos;
}

class _RecursoHome {
  const _RecursoHome({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.rota,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final String rota;
}
