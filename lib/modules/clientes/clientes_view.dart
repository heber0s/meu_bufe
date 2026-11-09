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
                child: TextField(
                  onChanged: (valor) => controller.busca.value = valor,
                  decoration: InputDecoration(
                    hintText: 'Buscar cliente',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.roseGold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
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
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EstadoVazioClientes(),
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

class _EstadoVazioClientes extends StatelessWidget {
  const _EstadoVazioClientes();

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
              'Nenhum cliente cadastrado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Adicione o primeiro cliente para começar.',
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
