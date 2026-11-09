import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Value;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/database/app_database.dart';
import '../../routes/app_routes.dart';

class NotificacaoService extends GetxService {
  final AppDatabase db = Get.find<AppDatabase>();
  final _plugin = FlutterLocalNotificationsPlugin();

  // Regras dos lembretes (ajuste à vontade)
  static const horaDaVespera = 9; // 09:00 do dia anterior
  static const antecedenciaNoDia = Duration(hours: 3); // 3h antes do início
  static const _inicioIdsRetorno = 1000000000;
  static const _idNotificacaoTeste = 999999;

  static const _detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      'lembretes_eventos',
      'Lembretes de eventos',
      channelDescription: 'Avisos de eventos próximos da agenda',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFD4AF37),
    ),
  );

  static const _detalhesRetorno = NotificationDetails(
    android: AndroidNotificationDetails(
      'lembretes_orcamentos',
      'Retorno de orçamentos',
      channelDescription: 'Lembretes para retomar contato sobre propostas',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFB76E79),
    ),
  );

  StreamSubscription<List<Evento>>? _sub;
  bool _rodando = false;
  bool _repetir = false;

  /// Chamado uma vez no main(): Get.putAsync(() => NotificacaoService().init())
  Future<NotificacaoService> init() async {
    tz.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _aoTocar,
    );

    // Android 13+: pede a permissão de notificações
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Restaura os lembretes de retorno salvos no banco após abrir o app.
    await _sincronizarRetornos();

    // Qualquer mudança na agenda reagenda os lembretes
    _sub = (db.select(db.eventos)
          ..where((e) => e.inicio.isBiggerThanValue(DateTime.now())))
        .watch()
        .listen((_) => _reagendar());

    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // Evita duas rodadas simultâneas: se mudar de novo no meio, repete no fim
  Future<void> _reagendar() async {
    if (_rodando) {
      _repetir = true;
      return;
    }
    _rodando = true;
    try {
      do {
        _repetir = false;
        await _aplicar();
      } while (_repetir);
    } finally {
      _rodando = false;
    }
  }

  Future<void> _aplicar() async {
    // Reagenda apenas notificações de eventos; preserva retornos de orçamento.
    final pendentes = await _plugin.pendingNotificationRequests();
    for (final pendente in pendentes) {
      if (pendente.id < _inicioIdsRetorno &&
          pendente.id != _idNotificacaoTeste) {
        await _plugin.cancel(id: pendente.id);
      }
    }

    final agora = DateTime.now();
    final eventos = await (db.select(db.eventos)
          ..where((e) => e.inicio.isBiggerThanValue(agora)))
        .get();

    for (final e in eventos) {
      final hora = '${e.inicio.hour.toString().padLeft(2, '0')}:'
          '${e.inicio.minute.toString().padLeft(2, '0')}';
      final local = e.local == null ? '' : ' · ${e.local}';

      // IDs estáveis por evento: id*10+1 (véspera) e id*10+2 (no dia)
      await _agendar(
        id: e.id * 10 + 1,
        evento: e,
        quando: DateTime(
            e.inicio.year, e.inicio.month, e.inicio.day - 1, horaDaVespera),
        corpo: 'Amanhã às $hora$local',
      );
      await _agendar(
        id: e.id * 10 + 2,
        evento: e,
        quando: e.inicio.subtract(antecedenciaNoDia),
        corpo: 'Hoje às $hora$local',
      );
    }
  }

  Future<void> _agendar({
    required int id,
    required Evento evento,
    required DateTime quando,
    required String corpo,
  }) async {
    if (!quando.isAfter(DateTime.now())) return; // já passou

    await _plugin.zonedSchedule(
      id: id,
      title: evento.titulo,
      body: corpo,
      scheduledDate: tz.TZDateTime.from(quando, tz.UTC),
      notificationDetails: _detalhes,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: evento.orcamentoId?.toString(),
    );
  }

  int _idRetorno(int orcamentoId) => _inicioIdsRetorno + orcamentoId;

  /// Agenda ou substitui o lembrete de retorno de um orçamento.
  Future<void> agendarRetorno({
    required int orcamentoId,
    required String titulo,
    required String cliente,
    required String resumo,
    required DateTime quando,
  }) async {
    final id = _idRetorno(orcamentoId);
    await _plugin.cancel(id: id);
    if (!quando.isAfter(DateTime.now())) return;

    final complemento = resumo.trim().isEmpty ? '' : ' · ${resumo.trim()}';
    await _plugin.zonedSchedule(
      id: id,
      title: 'Retomar orçamento: $titulo',
      body: 'Contato com $cliente$complemento',
      scheduledDate: tz.TZDateTime.from(quando, tz.UTC),
      notificationDetails: _detalhesRetorno,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: orcamentoId.toString(),
    );
  }

  Future<void> cancelarRetorno(int orcamentoId) =>
      _plugin.cancel(id: _idRetorno(orcamentoId));

  Future<void> _sincronizarRetornos() async {
    final linhas = await db.customSelect('''
      SELECT atual.orcamento_id, atual.proximo_retorno, atual.resumo,
             o.titulo, c.nome AS cliente_nome
      FROM orcamento_acompanhamentos atual
      JOIN (
        SELECT orcamento_id, MAX(id) AS ultimo_id
        FROM orcamento_acompanhamentos
        GROUP BY orcamento_id
      ) ultimos ON ultimos.ultimo_id = atual.id
      JOIN orcamentos o ON o.id = atual.orcamento_id
      JOIN clientes c ON c.id = o.cliente_id
      WHERE atual.proximo_retorno IS NOT NULL
        AND LOWER(TRIM(o.status)) NOT IN ('aprovado', 'perdido')
    ''').get();

    for (final linha in linhas) {
      final quando = DateTime.fromMillisecondsSinceEpoch(
        linha.read<int>('proximo_retorno'),
      );
      if (!quando.isAfter(DateTime.now())) continue;
      await agendarRetorno(
        orcamentoId: linha.read<int>('orcamento_id'),
        titulo: linha.read<String>('titulo'),
        cliente: linha.read<String>('cliente_nome'),
        resumo: linha.read<String>('resumo'),
        quando: quando,
      );
    }
  }

  /// Tocar na notificação abre o detalhe do orçamento vinculado
  void _aoTocar(NotificationResponse resposta) {
    final id = int.tryParse(resposta.payload ?? '');
    if (id != null) Get.toNamed(Routes.detalhe(id));
  }

  /// Para testar: dispara uma notificação em 10 segundos.
  /// Atenção: qualquer mudança na agenda nesse intervalo faz o reagendamento
  /// cancelar o teste.
  Future<void> testar() => _plugin.zonedSchedule(
        id: _idNotificacaoTeste,
        title: 'Lembrete de teste',
        body: 'As notificações estão funcionando.',
        scheduledDate: tz.TZDateTime.from(
            DateTime.now().add(const Duration(seconds: 10)), tz.UTC),
        notificationDetails: _detalhes,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
}