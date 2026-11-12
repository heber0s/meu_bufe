import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/database/app_database.dart';
import '../../routes/app_routes.dart';
import 'clientes_controller.dart';

class ClientesView extends GetView<ClientesController> {
  const ClientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clientes',
                            style:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sua lista de contatos e celebrações.',
                            style: TextStyle(
                              color: AppColors.texto.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Novo cliente',
                      onPressed: () => controller.abrirFormulario(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ouro,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Obx(() {
                  final temBusca = controller.busca.value.isNotEmpty;
                  return TextField(
                    controller: controller.buscaController,
                    onChanged: controller.atualizarBusca,
                    decoration: InputDecoration(
                      hintText: 'Buscar cliente por nome, telefone ou e-mail',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.roseGold,
                      ),
                      suffixIcon: temBusca
                          ? IconButton(
                              tooltip: 'Limpar busca',
                              onPressed: controller.limparBusca,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Obx(() {
                  final selecionado = controller.filtroOrcamentos.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FiltroClientesChip(
                          rotulo: 'Todos',
                          quantidade: controller.clientes.length,
                          selecionado: selecionado == 'todos',
                          aoSelecionar: () =>
                              controller.filtroOrcamentos.value = 'todos',
                        ),
                        const SizedBox(width: 8),
                        _FiltroClientesChip(
                          rotulo: 'Com orçamento',
                          quantidade: controller.quantidadeComOrcamento,
                          selecionado: selecionado == 'com_orcamento',
                          aoSelecionar: () => controller.filtroOrcamentos.value =
                              'com_orcamento',
                        ),
                        const SizedBox(width: 8),
                        _FiltroClientesChip(
                          rotulo: 'Sem orçamento',
                          quantidade: controller.quantidadeSemOrcamento,
                          selecionado: selecionado == 'sem_orcamento',
                          aoSelecionar: () => controller.filtroOrcamentos.value =
                              'sem_orcamento',
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Obx(() {
              if (controller.carregando.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.ouro,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final lista = controller.clientesFiltrados;

              if (lista.isEmpty) {
                final vazioPorBuscaOuFiltro = controller.busca.value.trim().isNotEmpty ||
                    controller.filtroOrcamentos.value != 'todos';
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EstadoVazioClientes(
                    buscaOuFiltro: vazioPorBuscaOuFiltro,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                sliver: SliverList.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _ClienteCard(cliente: lista[index]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  const _ClienteCard({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientesController>();

    return PressableScale(
      onTap: () => Get.toNamed(Routes.clienteDetalhe(cliente.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.champagne,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _iniciais(cliente.nome),
                style: const TextStyle(
                  color: AppColors.roseGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                  if (cliente.telefone != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      cliente.telefone!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.texto.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  if (cliente.email != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      cliente.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.texto.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  if (controller.orcamentosDoCliente(cliente.id) > 0) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: AppColors.roseGold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${controller.orcamentosDoCliente(cliente.id)} ${controller.orcamentosDoCliente(cliente.id) == 1 ? 'orçamento' : 'orçamentos'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.texto.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) async {
                if (opcao == 'editar') {
                  controller.abrirFormulario(cliente: cliente);
                }

                if (opcao == 'excluir') {
                  await controller.excluirCliente(cliente);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) {
      return '?';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _FiltroClientesChip extends StatelessWidget {
  const _FiltroClientesChip({
    required this.rotulo,
    required this.quantidade,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final String rotulo;
  final int quantidade;
  final bool selecionado;
  final VoidCallback aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selecionado,
      onSelected: (_) => aoSelecionar(),
      showCheckmark: false,
      label: Text('$rotulo  $quantidade'),
      selectedColor: AppColors.champagne,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selecionado ? AppColors.ouro : AppColors.texto.withValues(alpha: 0.08),
      ),
      labelStyle: TextStyle(
        color: selecionado ? AppColors.texto : AppColors.texto.withValues(alpha: 0.72),
        fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _EstadoVazioClientes extends StatelessWidget {
  const _EstadoVazioClientes({this.buscaOuFiltro = false});

  final bool buscaOuFiltro;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppColors.champagne,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 38,
                color: AppColors.roseGold,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              buscaOuFiltro ? 'Nenhum cliente encontrado' : 'Nenhum cliente cadastrado',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              buscaOuFiltro
                  ? 'Ajuste a busca ou escolha outro filtro.'
                  : 'Adicione o primeiro cliente para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.texto.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
