import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';

class EmpresaService extends GetxService {
  final AppDatabase db = Get.find<AppDatabase>();

  /// Logo padrão do app (declare no pubspec.yaml e ajuste o caminho)
  static const logoPadraoAsset = 'assets/images/logo.png';

  /// Valores aceitos em [modoOperacao]
  static const modoSomenteServico = 'somenteServico';
  static const modoCompleto = 'completo';

  final nome = 'Seu Bufê'.obs;
  final telefone = ''.obs;
  final email = ''.obs;
  final validadeDias = 15.obs;
  final logoPersonalizado = Rxn<Uint8List>(); // null = usando o logo do app

  StreamSubscription<Empresa?>? _sub;

  SimpleSelectStatement<$EmpresasTable, Empresa> get _consulta =>
      db.select(db.empresas)..where((e) => e.id.equals(1));

  /// Chamado uma vez no main(), depois de registrar o AppDatabase
  Future<EmpresaService> init() async {
    _aplicar(await _consulta.getSingleOrNull()); // valores prontos antes do runApp
    _sub = _consulta.watchSingleOrNull().listen(_aplicar);
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _aplicar(Empresa? e) {
    nome.value = e?.nome ?? 'Seu Bufê';
    telefone.value = e?.telefone ?? '';
    email.value = e?.email ?? '';
    validadeDias.value = e?.validadeDias ?? 15;
    logoPersonalizado.value = e?.logo;
  }

  /// Linha de contato do rodapé do PDF (ignora campos vazios)
  String get contatoLinha => [email.value, telefone.value]
      .where((c) => c.trim().isNotEmpty)
      .join('  |  ');

  /// Salva os dados de texto sem tocar no logo
  Future<void> salvarDados({
    required String nome,
    required String telefone,
    required String email,
    required int validadeDias,
  }) =>
      db.into(db.empresas).insertOnConflictUpdate(EmpresasCompanion(
            id: const Value(1),
            nome: Value(nome),
            telefone: Value(telefone.isEmpty ? '' : telefone),
            email: Value(email.isEmpty ? '' : email),
            validadeDias: Value(validadeDias),
          ));

  Future<void> salvarLogo(Uint8List bytes) =>
      db.into(db.empresas).insertOnConflictUpdate(
            EmpresasCompanion(id: const Value(1), logo: Value(bytes)),
          );

  /// Volta a usar o logo do app
  Future<void> removerLogo() => db.into(db.empresas).insertOnConflictUpdate(
        const EmpresasCompanion(id: Value(1), logo: Value(null)),
      );

  /// Bytes do logo a usar no PDF: o do usuário ou, se não houver, o do app.
  /// Devolve null se nem o asset for encontrado (o PDF sai sem logo).
  Future<Uint8List?> logoParaPdf() async {
    final proprio = logoPersonalizado.value;
    if (proprio != null) return proprio;
    try {
      final dados = await rootBundle.load(logoPadraoAsset);
      return dados.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}