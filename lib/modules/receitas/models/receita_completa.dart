import '../../../data/database/app_database.dart';

class ReceitaCompleta {
  const ReceitaCompleta({
    required this.receita,
    required this.ingredientes,
  });

  final Receita receita;
  final List<ReceitaIngrediente> ingredientes;
}