// modules/receitas/models/ingrediente_calculado.dart
class IngredienteCalculado {
  const IngredienteCalculado({
    required this.produto,
    required this.quantidadeMilesimos,
    required this.unidade,
    required this.quantidadeFormatada,
    required this.precoCentavos,
  });

  final String produto;
  final int quantidadeMilesimos;
  final String unidade;
  final String quantidadeFormatada;
  final int? precoCentavos;
}