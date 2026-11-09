abstract class Routes {
  Routes._();

  static const home = '/home';
  static const orcamentoForm = '/orcamento-form'; // criar ou editar (id opcional via arguments)
  static const orcamentoDetalhe = '/orcamentos/:id';
  static const agenda = '/agenda';
  static const clientes = '/clientes';
  static const ajustes = '/ajustes';
  static const receitas = '/receitas';
  static const servicos = '/servicos';
  static const catalogo = '/catalogo';
  static const funilVendas = '/funil-vendas';

  // Helper para rotas com parâmetro: Get.toNamed(Routes.detalhe(orcamento.id))
  static String detalhe(int id) => '/orcamentos/$id';
}