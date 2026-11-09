import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  TextColumn get telefone => text().nullable()();
  TextColumn get email => text().nullable()();
}

class Servicos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 150)();

  /// Preço sugerido em centavos. Pode não ser informado.
  IntColumn get precoCentavos => integer().nullable()();

  // Valores esperados: porConvidado, porUnidade ou geral.
  TextColumn get tipoCobranca =>
      text().withDefault(const Constant('geral'))();

  BoolColumn get ativo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

class Orcamentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  TextColumn get titulo => text()();
  DateTimeColumn get dataEvento => dateTime()();
  TextColumn get local => text().nullable()();
  IntColumn get convidados => integer().withDefault(const Constant(0))();
  IntColumn get descontoCentavos => integer().withDefault(const Constant(0))();

  // true: o bufê compra os ingredientes; false: o cliente compra.
  BoolColumn get ingredientesCompradosPeloBufe =>
      boolean().withDefault(const Constant(true))();

  TextColumn get status =>
      text().withDefault(const Constant('pendente'))();

  TextColumn get observacoes => text().nullable()();
}

class OrcamentoItens extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orcamentoId => integer().references(Orcamentos, #id)();
  TextColumn get nome => text()();
  IntColumn get quantidade => integer().withDefault(const Constant(1))();
  IntColumn get precoCentavos => integer().withDefault(const Constant(0))();
  TextColumn get tipoCobranca =>
      text().withDefault(const Constant('geral'))();

  // Valores: ingrediente ou servico.
  TextColumn get categoria =>
      text().withDefault(const Constant('servico'))();

  IntColumn get receitaId => integer().nullable()();
  IntColumn get receitaIngredienteId => integer().nullable()();
  TextColumn get receitaNome => text().nullable()();
  TextColumn get unidade => text().nullable()();
  IntColumn get quantidadeMilesimos =>
      integer().withDefault(const Constant(1000))();
  IntColumn get servicoId => integer().nullable().references(Servicos, #id)();
}

class Eventos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orcamentoId =>
      integer().nullable().references(Orcamentos, #id)();
  TextColumn get titulo => text()();
  TextColumn get local => text().nullable()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fim => dateTime()();
}

class Empresas extends Table {
  IntColumn get id => integer()();
  TextColumn get nome => text().withDefault(const Constant('Seu Bufê'))();
  TextColumn get telefone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  IntColumn get validadeDias => integer().withDefault(const Constant(15))();
  BlobColumn get logo => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Receitas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 150)();
  IntColumn get rendimentoPessoas => integer()();
  DateTimeColumn get criadoEm =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get atualizadoEm =>
      dateTime().withDefault(currentDateAndTime)();
}

class ReceitaIngredientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get receitaId => integer().references(Receitas, #id)();
  TextColumn get produto => text().withLength(min: 1, max: 150)();

  /// Quantidade armazenada em milésimos da unidade.
  IntColumn get quantidadeMilesimos => integer()();

  /// Exemplos: g, kg, ml, l, un, cabeça, pacote.
  TextColumn get unidade => text().withLength(min: 1, max: 30)();

  /// Preço estimado do ingrediente, em centavos. Pode ser nulo.
  IntColumn get precoCentavos => integer().nullable()();

  DateTimeColumn get criadoEm =>
      dateTime().withDefault(currentDateAndTime)();

  List<Index> get indexes => [
        Index(
          'receita_ingredientes_receita_idx',
          'CREATE INDEX receita_ingredientes_receita_idx '
              'ON receita_ingredientes (receita_id)',
        ),
      ];
}

class OrcamentoReceitas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orcamentoId => integer().references(Orcamentos, #id)();
  IntColumn get receitaId => integer().references(Receitas, #id)();

  /// Fator calculado no momento da inclusão.
  IntColumn get fatorMilesimos => integer()();

  /// Quantidade de convidados usada ao incluir a receita.
  IntColumn get convidadosNoMomento => integer()();

  DateTimeColumn get adicionadaEm =>
      dateTime().withDefault(currentDateAndTime)();

  List<Index> get indexes => [
        Index(
          'orcamento_receitas_orcamento_idx',
          'CREATE INDEX orcamento_receitas_orcamento_idx '
              'ON orcamento_receitas (orcamento_id)',
        ),
      ];
}

@DriftDatabase(
  tables: [
    Clientes,
    Orcamentos,
    OrcamentoItens,
    Eventos,
    Empresas,
    Receitas,
    ReceitaIngredientes,
    OrcamentoReceitas,
    Servicos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  // Schema inicial novo. Como você vai testar com banco limpo, não precisamos
  // manter a sequência de migrações do schema antigo.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await migrator.createAll();
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS orcamento_acompanhamentos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              orcamento_id INTEGER NOT NULL,
              contato_em INTEGER NOT NULL,
              canal TEXT NOT NULL,
              resumo TEXT NOT NULL,
              proximo_retorno INTEGER,
              FOREIGN KEY (orcamento_id) REFERENCES orcamentos(id)
                ON DELETE CASCADE
            )
          ''');
          await customStatement('''
            CREATE INDEX IF NOT EXISTS orcamento_acompanhamentos_orcamento_idx
            ON orcamento_acompanhamentos (orcamento_id, contato_em DESC)
          ''');
        },
      );
}

LazyDatabase _open() => LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();

      return NativeDatabase.createInBackground(
        File(p.join(directory.path, 'bufe.sqlite')),
      );
    });