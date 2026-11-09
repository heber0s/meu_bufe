import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class CatalogoView extends StatelessWidget {
  const CatalogoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catálogo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cadastros reutilizáveis para montar seus orçamentos.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.texto.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          _CatalogoCard(
            icone: Icons.restaurant_menu_rounded,
            titulo: 'Receitas',
            descricao: 'Gerencie receitas e seus ingredientes.',
            onTap: () => Get.toNamed(Routes.receitas),
          ),
          const SizedBox(height: 14),
          _CatalogoCard(
            icone: Icons.room_service_outlined,
            titulo: 'Serviços',
            descricao: 'Gerencie serviços e valores sugeridos.',
            onTap: () => Get.toNamed(Routes.servicos),
          ),
        ],
      ),
    );
  }
}

class _CatalogoCard extends StatelessWidget {
  const _CatalogoCard({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.sombraSutil,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.champagne,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icone,
                  color: AppColors.roseGold,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.texto.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.texto.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}