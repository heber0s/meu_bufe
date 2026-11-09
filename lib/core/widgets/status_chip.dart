import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  /// 'pendente' | 'aprovado' | 'recusado'
  final String status;

  @override
  Widget build(BuildContext context) {
    final (fundo, texto, rotulo) = switch (status) {
      'aprovado' => (AppColors.aprovado, const Color(0xFF5E7350), 'Aprovado'),
      'recusado' => (Colors.grey, const Color(0xFF6B6B6B), 'Recusado'),
      _ => (AppColors.pendente, const Color(0xFFB5694A), 'Pendente'),
    };

    // AnimatedContainer: ao aprovar um orçamento a cor "escorre" para o verde
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: texto,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}