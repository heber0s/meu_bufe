import 'package:get/get.dart';

import '../modules/agenda/agenda_binding.dart';
import '../modules/agenda/agenda_view.dart';
import '../modules/ajustes/ajustes_controller.dart';
import '../modules/ajustes/ajustes_view.dart';
import '../modules/catalogo/catalogo_view.dart';
import '../modules/clientes/cliente_detalhe_binding.dart';
import '../modules/clientes/cliente_detalhe_view.dart';
import '../modules/clientes/clientes_binding.dart';
import '../modules/clientes/clientes_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/orcamentos/orcamento_detalhe_binding.dart';
import '../modules/orcamentos/orcamento_detalhe_view.dart';
import '../modules/orcamentos/orcamento_form_binding.dart';
import '../modules/orcamentos/orcamento_form_view.dart';
import '../modules/orcamentos/funil_vendas_view.dart';
import '../modules/relatorios/relatorios_binding.dart';
import '../modules/relatorios/relatorios_view.dart';
import '../modules/retornos/retornos_binding.dart';
import '../modules/retornos/retornos_view.dart';
import '../modules/receitas/receitas_binding.dart';
import '../modules/receitas/receitas_view.dart';
import '../modules/servicos/servicos_binding.dart';
import '../modules/servicos/servicos_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  AppPages._();

  static const _duracao = Duration(milliseconds: 400);

  static final pages = <GetPage>[
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.orcamentoForm,
      page: () => const OrcamentoFormView(),
      binding: OrcamentoFormBinding(),
      transition: Transition.downToUp,
      transitionDuration: _duracao,
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.orcamentoDetalhe,
      page: () => const OrcamentoDetalheView(),
      binding: OrcamentoDetalheBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.funilVendas,
      page: () => const FunilVendasView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.relatorios,
      page: () => const RelatoriosView(),
      binding: RelatoriosBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.retornos,
      page: () => const RetornosView(),
      binding: RetornosBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.agenda,
      page: () => const AgendaView(),
      binding: AgendaBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.clientes,
      page: () => const ClientesView(),
      binding: ClientesBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.clienteDetalhePath,
      page: () => const ClienteDetalheView(),
      binding: ClienteDetalheBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.ajustes,
      page: () => const AjustesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AjustesController())),
    ),
    GetPage(
      name: Routes.receitas,
      page: () => const ReceitasView(),
      binding: ReceitasBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.servicos,
      page: () => const ServicosView(),
      binding: ServicosBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
    GetPage(
      name: Routes.catalogo,
      page: () => const CatalogoView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: _duracao,
    ),
  ];
}
