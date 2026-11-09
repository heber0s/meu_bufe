import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/database/app_database.dart';
import 'receitas_controller.dart';

class ReceitasView extends GetView<ReceitasController> {
  const ReceitasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Receitas'),
        actions: [
          IconButton(
            tooltip: 'Nova receita',
            onPressed: () => controller.abrirFormulario(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.ouro,
        foregroundColor: Colors.white,
        onPressed: () => controller.abrirFormulario(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova receita'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Text(
                  'Cadastre receitas e dimensione os ingredientes '
                  'automaticamente para cada evento.',
                  style: TextStyle(
                    height: 1.4,
                    color: AppColors.texto.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                child: TextField(
                  onChanged: (valor) => controller.busca.value = valor,
                  decoration: InputDecoration(
                    hintText: 'Buscar receita',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.roseGold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
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

              final lista = controller.receitasFiltradas;

              if (lista.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EstadoVazioReceitas(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                sliver: SliverList.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _ReceitaCard(
                      receita: lista[index],
                      onEditar: () => controller.abrirFormulario(
                        receita: lista[index],
                      ),
                      onExcluir: () => controller.excluirReceita(
                        lista[index],
                      ),
                    );
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

class _ReceitaCard extends StatelessWidget {
  const _ReceitaCard({
    required this.receita,
    required this.onEditar,
    required this.onExcluir,
  });

  final Receita receita;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onEditar,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.champagne,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.roseGold,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 17,
                        color: AppColors.roseGold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Rende ${receita.rendimentoPessoas} pessoas',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.texto.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opções',
              onSelected: (valor) {
                if (valor == 'editar') {
                  onEditar();
                }

                if (valor == 'excluir') {
                  onExcluir();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 10),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazioReceitas extends StatelessWidget {
  const _EstadoVazioReceitas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: AppColors.champagne,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: AppColors.roseGold,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhuma receita cadastrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.texto,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Cadastre uma receita para usar seus ingredientes '
              'automaticamente nos orçamentos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.4,
                color: AppColors.texto.withValues(alpha: 0.58),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                Get.find<ReceitasController>().abrirFormulario();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ouro,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Cadastrar receita'),
            ),
          ],
        ),
      ),
    );
  }
}