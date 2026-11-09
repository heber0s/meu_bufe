import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/empresa_service.dart';
import 'core/services/notificacao_service.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  Get.put(AppDatabase(), permanent: true); // banco vive durante todo o app
  await Get.putAsync(() => EmpresaService().init(), permanent: true);
  await Get.putAsync(() => NotificacaoService().init(), permanent: true);
  runApp(const BufeApp());
}

class BufeApp extends StatelessWidget {
  const BufeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Meu Bufê',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: Routes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}