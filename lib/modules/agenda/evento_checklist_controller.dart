import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:get/get.dart';

import '../../data/database/app_database.dart';

class EventoChecklistTarefa {
  const EventoChecklistTarefa({
    required this.id,
    required this.titulo,
    required this.responsavel,
    required this.prazo,
    required this.concluida,
  });

  final int id;
  final String titulo;
  final String? responsavel;
  final DateTime? prazo;
  final bool concluida;

  factory EventoChecklistTarefa.fromRow(QueryRow row) {
    final prazoEm = row.readNullable<int>('prazo_em');

    return EventoChecklistTarefa(
      id: row.read<int>('id'),
      titulo: row.read<String>('titulo'),
      responsavel: row.readNullable<String>('responsavel'),
      prazo: prazoEm == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(prazoEm),
      concluida: row.read<int>('concluida') == 1,
    );
  }
}

class EventoChecklistController extends GetxController {
  EventoChecklistController({required this.eventoId});

  final int eventoId;
  final AppDatabase _db = Get.find<AppDatabase>();

  final tarefas = <EventoChecklistTarefa>[].obs;
  final carregando = true.obs;
  final erro = ''.obs;
  final salvando = false.obs;

  int get concluidas => tarefas.where((tarefa) => tarefa.concluida).length;

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    carregando.value = true;
    erro.value = '';

    try {
      final rows = await _db.customSelect(
        '''
        SELECT id, titulo, responsavel, prazo_em, concluida
        FROM evento_checklist_itens
        WHERE evento_id = ?
        ORDER BY concluida ASC, ordem ASC, id ASC
        ''',
        variables: [Variable.withInt(eventoId)],
      ).get();

      tarefas.assignAll(rows.map(EventoChecklistTarefa.fromRow));
    } catch (e) {
      erro.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      carregando.value = false;
    }
  }

  Future<void> adicionar({
    required String titulo,
    String? responsavel,
    DateTime? prazo,
  }) async {
    final tituloLimpo = titulo.trim();
    if (tituloLimpo.isEmpty) {
      throw Exception('Informe a tarefa.');
    }

    salvando.value = true;
    try {
      await _db.customStatement(
        '''
        INSERT INTO evento_checklist_itens (
          evento_id, titulo, responsavel, prazo_em, concluida, ordem, criado_em
        ) VALUES (?, ?, ?, ?, 0, ?, ?)
        ''',
        [
          eventoId,
          tituloLimpo,
          _limpar(responsavel),
          prazo?.millisecondsSinceEpoch,
          tarefas.length,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
      await carregar();
    } finally {
      salvando.value = false;
    }
  }

  Future<void> alternarConclusao(EventoChecklistTarefa tarefa) async {
    final novoValor = tarefa.concluida ? 0 : 1;
    await _db.customStatement(
      '''
      UPDATE evento_checklist_itens
      SET concluida = ?
      WHERE id = ? AND evento_id = ?
      ''',
      [novoValor, tarefa.id, eventoId],
    );
    await carregar();
  }

  Future<void> excluir(EventoChecklistTarefa tarefa) async {
    await _db.customStatement(
      '''
      DELETE FROM evento_checklist_itens
      WHERE id = ? AND evento_id = ?
      ''',
      [tarefa.id, eventoId],
    );
    await carregar();
  }

  String? _limpar(String? valor) {
    final limpo = valor?.trim();
    return limpo == null || limpo.isEmpty ? null : limpo;
  }
}
