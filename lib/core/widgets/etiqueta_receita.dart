import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EtiquetaReceita extends StatelessWidget {
  const EtiquetaReceita(this.nome, {super.key});
  final String nome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.champagne,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded,
              size: 12, color: AppColors.roseGold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              nome,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.roseGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}