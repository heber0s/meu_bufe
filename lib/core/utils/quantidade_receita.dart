class QuantidadeReceitaUtils {
  const QuantidadeReceitaUtils._();

  static int calcularMilesimos({
    required int quantidadeBaseMilesimos,
    required int convidados,
    required int rendimentoPessoas,
    required String unidade,
  }) {
    if (rendimentoPessoas <= 0) {
      throw ArgumentError(
        'O rendimento da receita precisa ser maior que zero.',
      );
    }

    if (convidados <= 0) {
      return 0;
    }

    return ((quantidadeBaseMilesimos * convidados) / rendimentoPessoas).round();
  }

  static String formatar({
    required int quantidadeMilesimos,
    required String unidade,
  }) {
    final quantidade = quantidadeMilesimos / 1000;

    final texto = quantidade
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');

    return '$texto $unidade';
  }

  static double paraDouble(int quantidadeMilesimos) {
    return quantidadeMilesimos / 1000;
  }

  static int paraMilesimos(double quantidade) {
    return (quantidade * 1000).round();
  }
}