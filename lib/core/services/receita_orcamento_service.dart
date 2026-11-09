import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';

class ReceitaOrcamentoService {
  const ReceitaOrcamentoService(this.db);

  final AppDatabase db;

  Future<void> adicionarReceitaAoOrcamento({
    required int orcamentoId,
    required int convidados,
    required int receitaId,
  }) async {
    if (convidados <= 0) {
      throw Exception(
        'Informe uma quantidade de convidados maior que zero.',
      );
    }

    final receita = await (db.select(db.receitas)
          ..where((item) => item.id.equals(receitaId)))
        .getSingleOrNull();

    if (receita == null) {
      throw Exception('A receita selecionada não foi encontrada.');
    }

    if (receita.rendimentoPessoas <= 0) {
      throw Exception(
        'O rendimento da receita precisa ser maior que zero.',
      );
    }

    final ingredientes = await (db.select(db.receitaIngredientes)
          ..where((item) => item.receitaId.equals(receitaId))
          ..orderBy([
            (item) => OrderingTerm(
                  expression: item.id,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();

    if (ingredientes.isEmpty) {
      throw Exception(
        'A receita selecionada não possui ingredientes.',
      );
    }

    final fatorMilesimos =
        ((convidados * 1000) / receita.rendimentoPessoas).round();

    await db.transaction(() async {
      await db.into(db.orcamentoReceitas).insert(
            OrcamentoReceitasCompanion.insert(
              orcamentoId: orcamentoId,
              receitaId: receitaId,
              fatorMilesimos: fatorMilesimos,
              convidadosNoMomento: convidados,
            ),
          );

      for (final ingrediente in ingredientes) {
        final quantidadeCalculada =
            ((ingrediente.quantidadeMilesimos * convidados) /
                    receita.rendimentoPessoas)
                .round();

        // O preço cadastrado no ingrediente é o custo da quantidade usada
        // na receita cadastrada. Escalamos esse custo para os convidados do
        // orçamento, conservando o valor original em centavos sempre que o
        // fator produzir um resultado inteiro.
        final precoOriginalCentavos = ingrediente.precoCentavos ?? 0;
        final precoCalculadoCentavos =
            (precoOriginalCentavos * convidados /
                    receita.rendimentoPessoas)
                .round();

        await db.into(db.orcamentoItens).insert(
              OrcamentoItensCompanion.insert(
                orcamentoId: orcamentoId,
                nome: ingrediente.produto,
                quantidade: const Value(1),
                precoCentavos: Value(precoCalculadoCentavos),
                tipoCobranca: const Value('geral'),
                categoria: const Value('ingrediente'),
                receitaId: Value(receita.id),
                receitaIngredienteId: Value(ingrediente.id),
                receitaNome: Value(receita.nome),
                unidade: Value(ingrediente.unidade),
                quantidadeMilesimos: Value(quantidadeCalculada),
              ),
            );
      }
    });
  }

  Future<void> removerReceitaDoOrcamento({
    required int orcamentoId,
    required int receitaId,
  }) async {
    await db.transaction(() async {
      await (db.delete(db.orcamentoItens)
            ..where(
              (item) =>
                  item.orcamentoId.equals(orcamentoId) &
                  item.receitaId.equals(receitaId),
            ))
          .go();

      await (db.delete(db.orcamentoReceitas)
            ..where(
              (item) =>
                  item.orcamentoId.equals(orcamentoId) &
                  item.receitaId.equals(receitaId),
            ))
          .go();
    });
  }

  Future<List<Receita>> listarReceitas() {
    return (db.select(db.receitas)
          ..orderBy([
            (item) => OrderingTerm(
                  expression: item.nome,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Stream<List<Receita>> observarReceitas() {
    return (db.select(db.receitas)
          ..orderBy([
            (item) => OrderingTerm(
                  expression: item.nome,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  Future<Receita?> buscarReceita(int receitaId) {
    return (db.select(db.receitas)
          ..where((item) => item.id.equals(receitaId)))
        .getSingleOrNull();
  }

  Future<List<ReceitaIngrediente>> listarIngredientes(int receitaId) {
    return (db.select(db.receitaIngredientes)
          ..where((item) => item.receitaId.equals(receitaId))
          ..orderBy([
            (item) => OrderingTerm(
                  expression: item.id,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }
}