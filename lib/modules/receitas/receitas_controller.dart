import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../data/database/app_database.dart';
import 'receita_form_sheet.dart';

class ReceitasController extends GetxController {
  ReceitasController({
    AppDatabase? database,
  }) : db = database ?? Get.find<AppDatabase>();

  final AppDatabase db;

  final receitas = <Receita>[].obs;
  final busca = ''.obs;
  final carregando = true.obs;
  final processando = false.obs;

  StreamSubscription<List<Receita>>? _subscription;

  List<Receita> get receitasFiltradas {
    final termo = _normalizar(busca.value);

    if (termo.isEmpty) {
      return receitas.toList();
    }

    return receitas.where((receita) {
      return _normalizar(receita.nome).contains(termo);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _observarReceitas();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _observarReceitas() {
    _subscription?.cancel();

    final consulta = db.select(db.receitas)
      ..orderBy([
        (receita) => OrderingTerm(
              expression: receita.nome,
              mode: OrderingMode.asc,
            ),
      ]);

    _subscription = consulta.watch().listen(
      (lista) {
        receitas.assignAll(lista);
        carregando.value = false;
      },
      onError: (Object erro) {
        carregando.value = false;

        Get.snackbar(
          'Erro',
          'Não foi possível carregar as receitas.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> abrirFormulario({
    Receita? receita,
  }) async {
    List<ReceitaIngrediente> ingredientes = [];

    if (receita != null) {
      ingredientes = await (db.select(db.receitaIngredientes)
            ..where(
              (item) => item.receitaId.equals(receita.id),
            )
            ..orderBy([
              (item) => OrderingTerm(
                    expression: item.id,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();
    }

    final resultado = await Get.bottomSheet<ReceitaFormularioResultado>(
      ReceitaFormSheet(
        receita: receita,
        ingredientes: ingredientes,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );

    if (resultado == null) {
      return;
    }

    await _salvarReceita(
      resultado,
      receitaExistente: receita,
    );
  }

  Future<void> _salvarReceita(
    ReceitaFormularioResultado dados, {
    Receita? receitaExistente,
  }) async {
    if (processando.value) {
      return;
    }

    processando.value = true;

    try {
      await db.transaction(() async {
        final receitaId = receitaExistente == null
            ? await db.into(db.receitas).insert(
                  ReceitasCompanion.insert(
                    nome: dados.nome,
                    rendimentoPessoas: dados.rendimentoPessoas,
                  ),
                )
            : receitaExistente.id;

        if (receitaExistente != null) {
          await (db.update(db.receitas)
                ..where((receita) => receita.id.equals(receitaId)))
              .write(
            ReceitasCompanion(
              nome: Value(dados.nome),
              rendimentoPessoas: Value(dados.rendimentoPessoas),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

          await (db.delete(db.receitaIngredientes)
                ..where(
                  (ingrediente) =>
                      ingrediente.receitaId.equals(receitaId),
                ))
              .go();
        }

        for (final ingrediente in dados.ingredientes) {
          await db.into(db.receitaIngredientes).insert(
                ReceitaIngredientesCompanion.insert(
                  receitaId: receitaId,
                  produto: ingrediente.produto,
                  quantidadeMilesimos: ingrediente.quantidadeMilesimos,
                  unidade: ingrediente.unidade,
                  precoCentavos: Value(
                    ingrediente.precoCentavos,
                  ),
                ),
              );
        }
      });

      Get.snackbar(
        receitaExistente == null
            ? 'Receita cadastrada'
            : 'Receita atualizada',
        dados.nome,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar a receita.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  Future<void> excluirReceita(Receita receita) async {
    if (processando.value) {
      return;
    }

    final usadaEmOrcamento = await (db.select(db.orcamentoReceitas)
          ..where(
            (item) => item.receitaId.equals(receita.id),
          )
          ..limit(1))
        .getSingleOrNull();

    if (usadaEmOrcamento != null) {
      Get.snackbar(
        'Receita utilizada',
        'Esta receita já foi adicionada a um orçamento e não pode ser excluída.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text(
          'A receita "${receita.nome}" e seus ingredientes serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    processando.value = true;

    try {
      await db.transaction(() async {
        await (db.delete(db.receitaIngredientes)
              ..where(
                (item) => item.receitaId.equals(receita.id),
              ))
            .go();

        await (db.delete(db.receitas)
              ..where(
                (item) => item.id.equals(receita.id),
              ))
            .go();
      });

      Get.snackbar(
        'Receita removida',
        receita.nome,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (erro) {
      Get.snackbar(
        'Erro',
        'Não foi possível excluir a receita.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processando.value = false;
    }
  }

  String _normalizar(String texto) {
    const acentuadas = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

    var resultado = texto.trim().toLowerCase();

    for (var i = 0; i < acentuadas.length; i++) {
      resultado = resultado.replaceAll(
        acentuadas[i],
        semAcento[i],
      );
    }

    return resultado;
  }
}