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
    await _plugin.cancelAll();

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

  /// Tocar na notificação abre o detalhe do orçamento vinculado
  void _aoTocar(NotificationResponse resposta) {
    final id = int.tryParse(resposta.payload ?? '');
    if (id != null) Get.toNamed(Routes.detalhe(id));
  }

  /// Para testar: dispara uma notificação em 10 segundos.
  /// Atenção: qualquer mudança na agenda nesse intervalo faz o reagendamento
  /// cancelar o teste.
  Future<void> testar() => _plugin.zonedSchedule(
        id: 999999,
        title: 'Lembrete de teste',
        body: 'As notificações estão funcionando.',
        scheduledDate: tz.TZDateTime.from(
            DateTime.now().add(const Duration(seconds: 10)), tz.UTC),
        notificationDetails: _detalhes,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
}