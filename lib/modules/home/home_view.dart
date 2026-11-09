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
        actions: [
          IconButton(
            tooltip: 'Relatórios',
            onPressed: () => Get.toNamed(Routes.relatorios),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            tooltip: 'Funil de vendas',
            onPressed: () => Get.toNamed(Routes.funilVendas),
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
            tooltip: 'Catálogo',
            onPressed: () => Get.toNamed(Routes.catalogo),
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: 'Ajustes',
            onPressed: () => Get.toNamed(Routes.ajustes),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      extendBody: true,
      body: Obx(() => IndexedStack(
            index: controller.abaAtual.value,
            children: const [
              OrcamentosListaView(),
              AgendaView(),
              ClientesView(),
            ],
          )),
      floatingActionButton: Obx(() => AnimatedSwitcher(
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
          )),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Obx(() => NavigationBar(
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
                    selectedIcon: Icon(Icons.receipt_long_rounded,
                        color: AppColors.roseGold),
                    label: 'Orçamentos',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded,
                        color: AppColors.roseGold),
                    label: 'Agenda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_alt_rounded,
                        color: AppColors.roseGold),
                    label: 'Clientes',
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
