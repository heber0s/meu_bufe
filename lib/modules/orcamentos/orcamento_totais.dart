import '../../data/database/app_database.dart';

/// Centraliza os calculos financeiros de um orcamento.
class OrcamentoTotais {
  const OrcamentoTotais({
    required this.supermercadoCentavos,
    required this.combustivelETempoCentavos,
    required this.servicosCentavos,
    required this.descontoCentavos,
    required this.totalCentavos,
  });

  final int supermercadoCentavos;
  final int combustivelETempoCentavos;
  final int servicosCentavos;
  final int descontoCentavos;
  final int totalCentavos;

  int get subtotalCentavos =>
      supermercadoCentavos +
      combustivelETempoCentavos +
      servicosCentavos;

  factory OrcamentoTotais.calcular({
    required Orcamento orcamento,
    required List<OrcamentoIten> itens,
  }) {
    var totalIngredientes = 0;
    var totalServicos = 0;

    for (final item in itens) {
      final totalItem = totalDoItem(item, orcamento.convidados);

      if (item.categoria == 'ingrediente') {
        totalIngredientes += totalItem;
      } else {
        // Categorias desconhecidas sao contabilizadas como servico.
        totalServicos += totalItem;
      }
    }

    final bufeCompraIngredientes =
        orcamento.ingredientesCompradosPeloBufe;

    final supermercado =
        bufeCompraIngredientes ? totalIngredientes : 0;

    final combustivelETempo = bufeCompraIngredientes
        ? calcularVintePorCento(totalIngredientes)
        : 0;

    final subtotal = supermercado + combustivelETempo + totalServicos;
    final desconto = orcamento.descontoCentavos;

    return OrcamentoTotais(
      supermercadoCentavos: supermercado,
      combustivelETempoCentavos: combustivelETempo,
      servicosCentavos: totalServicos,
      descontoCentavos: desconto,
      totalCentavos: (subtotal - desconto).clamp(0, 0x7FFFFFFFFFFFFFFF),
    );
  }

  /// Calcula o total de uma linha conforme seu tipo de cobranca.
  ///
  /// Mantem compatibilidade com registros existentes que ainda usem
  /// `porConvidado`.
  static int totalDoItem(OrcamentoIten item, int convidados) {
    switch (item.tipoCobranca) {
      case 'porConvidado':
        return item.precoCentavos * convidados;
      case 'porUnidade':
        return item.precoCentavos * item.quantidade;
      case 'geral':
      default:
        return item.precoCentavos;
    }
  }

  /// Calcula 20% em centavos, arredondando para o centavo inteiro mais proximo.
  static int calcularVintePorCento(int valorCentavos) {
    if (valorCentavos <= 0) return 0;
    return (valorCentavos * 20 + 50) ~/ 100;
  }
}