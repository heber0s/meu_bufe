import 'dart:io';

import 'package:get/get.dart' hide Value;
import 'package:path_provider/path_provider.dart';

import '../../data/database/app_database.dart';

class BackupException implements Exception {
  BackupException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

class BackupService {
  static AppDatabase get _db => Get.find<AppDatabase>();
  static const _tabelasOpcionais = {'empresas'};

  static String _carimbo() {
    final d = DateTime.now();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${p(d.month)}-${p(d.day)}_${p(d.hour)}${p(d.minute)}';
  }

  /// Gera uma cópia consistente do banco em arquivo temporário
  static Future<File> gerarArquivo() async {
    final dir = await getTemporaryDirectory();
    final arquivo = File('${dir.path}/bufe_backup_${_carimbo()}.db');
    if (await arquivo.exists()) await arquivo.delete(); // VACUUM INTO exige arquivo novo

    await _db.customStatement('VACUUM INTO ?', [arquivo.path]);
    return arquivo;
  }

  /// Substitui os dados atuais pelos do arquivo de backup.
  /// Lança [BackupException] com uma mensagem amigável se algo estiver errado.
  static Future<void> restaurar(String caminho) async {
    final db = _db;

    // 1) Cópia de segurança do estado atual (permite desfazer)
    final docs = await getApplicationDocumentsDirectory();
    final seguranca = File('${docs.path}/antes_da_restauracao.db');
    if (await seguranca.exists()) await seguranca.delete();
    await db.customStatement('VACUUM INTO ?', [seguranca.path]);

    // 2) Anexa o backup (ATTACH não pode rodar dentro de transação)
    try {
      await db.customStatement('ATTACH DATABASE ? AS bkp', [caminho]);
    } catch (_) {
      throw BackupException('Não foi possível abrir o arquivo selecionado.');
    }

    try {
      final existentes = await _validar(db);

      await db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await db.transaction(() async {
          for (final t in db.allTables) {
            final nome = t.actualTableName;
            if (!existentes.contains(nome)) continue; // backup antigo: mantém o atual

            final colunas = t.$columns.map((c) => '"${c.$name}"').join(', ');

            await db.customStatement('DELETE FROM main."$nome"');
            await db.customStatement(
              'INSERT INTO main."$nome" ($colunas) '
              'SELECT $colunas FROM bkp."$nome"',
            );
          }

          final problemas =
              await db.customSelect('PRAGMA main.foreign_key_check').get();
          if (problemas.isNotEmpty) {
            throw BackupException(
                'O backup contém dados inconsistentes e não foi restaurado.');
          }
        });
      } finally {
        await db.customStatement('PRAGMA foreign_keys = ON');
      }
    } finally {
      await db.customStatement('DETACH DATABASE bkp');
    }

    // 3) Avisa todos os streams (lista, agenda, detalhe, notificações)
    db.markTablesUpdated(db.allTables);
  }

  static Future<Set<String>> _validar(AppDatabase db) async {
    try {
      final versao = (await db
              .customSelect('PRAGMA bkp.user_version')
              .getSingle())
          .read<int>('user_version');
      if (versao > db.schemaVersion) {
        throw BackupException(
            'Este backup foi feito por uma versão mais nova do app. '
            'Atualize o app antes de restaurar.');
      }

      final linhas = await db
          .customSelect("SELECT name FROM bkp.sqlite_master WHERE type = 'table'")
          .get();
      final existentes = linhas.map((r) => r.read<String>('name')).toSet();

      for (final t in db.allTables) {
        final nome = t.actualTableName;
        if (!existentes.contains(nome) && !_tabelasOpcionais.contains(nome)) {
          throw BackupException('O arquivo não parece ser um backup do Bufê.');
        }
      }
      return existentes;
    } on BackupException {
      rethrow;
    } catch (_) {
      // Arquivo que não é SQLite falha na primeira leitura
      throw BackupException('O arquivo não parece ser um backup do Bufê.');
    }
  }
}