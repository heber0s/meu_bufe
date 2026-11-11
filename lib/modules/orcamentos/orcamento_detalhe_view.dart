import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import 'orcamento_detalhe_controller.dart';
import 'widgets/orcamento_acompanhamento_section.dart';

class OrcamentoDetalheView extends GetView<OrcamentoDetalheController> {
  const OrcamentoDetalheView({super.key});

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final enabled = controller.podeEditar &&
          !controller.processando.value &&
          !controller.salvando.value;

      return PopupMenuButton<String>(
        enabled: enabled,
        tooltip: 'Adicionar item',
        onSelected: (opcao) {
          switch (opcao) {
            case 'manual':
              controller.abrirItemManual();
            case 'receita':
              controller.abrirSelecaoReceita();
            case 'servico':
              controller.abrirSelecaoServico();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'manual',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined),
              title: Text('Item manual'),
            ),
          ),
          PopupMenuItem<String>(
            value: 'receita',
            child: Row(
              children: [
                Icon(Icons.restaurant_menu_rounded),
                SizedBox(width: 12),
                Text('Adicionar receita'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'servico',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.room_service_outlined),
              title: Text('Serviço do catálogo'),
            ),
          ),
        ],
        child: Material(
          color: AppColors.ouro,
          elevation: 2,
          shape: const StadiumBorder(),
          child: const SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Adicionar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: Obx(() {
          final orcamento = controller.orcamento.value;

          return Text(
            orcamento?.titulo ?? 'Orçamento',
            overflow: TextOverflow.ellipsis,
          );
        }),
        actions: [
          Obx(() {
            final ocupado =
                controller.processando.value || controller.salvando.value;

            return PopupMenuButton<String>(
              enabled: !ocupado,
              tooltip: 'Mais opções',
              onSelected: (valor) {
                if (valor == 'copiar') controller.copiarOrcamento();
                if (valor == 'pdf') controller.gerarEEnviarPdf();
                if (valor == 'confirmar') controller.confirmarOrcamento();
                if (valor == 'reabrir') controller.reabrirOrcamento();
                if (valor == 'enviado') controller.marcarComoEnviado();
                if (valor == 'perdido') controller.marcarComoPerdido();
                if (valor == 'reabrir_negociacao') {
                  controller.reabrirParaNegociacao();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copiar',
                  child: Row(
                    children: [
                      Icon(Icons.copy_all_outlined),
                      SizedBox(width: 10),
                      Text('Copiar orçamento'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined),
                      SizedBox(width: 10),
                      Text('Gerar e enviar PDF'),
                    ],
                  ),
                ),
                if (controller.aprovado)
                  const PopupMenuItem(
                    value: 'reabrir',
                    child: Row(
                      children: [
                        Icon(Icons.lock_open_rounded),
                        SizedBox(width: 10),
                        Text('Reabrir orçamento'),
                      ],
                    ),
                  )
                else if (controller.perdido)
                  const PopupMenuItem(
                    value: 'reabrir_negociacao',
                    child: Row(
                      children: [
                        Icon(Icons.restart_alt_rounded),
                        SizedBox(width: 10),
                        Text('Reabrir para negociação'),
                      ],
                    ),
                  )
                else ...[
                  if (controller.orcamento.value?.status.toLowerCase() != 'enviado')
                    const PopupMenuItem(
                      value: 'enviado',
                      child: Row(
                        children: [
                          Icon(Icons.send_outlined, color: AppColors.roseGold),
                          SizedBox(width: 10),
                          Text('Marcar como enviado'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'perdido',
                    child: Row(
                      children: [
                        Icon(Icons.close_rounded, color: AppColors.terracota),
                        SizedBox(width: 10),
                        Text('Marcar como perdido'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'confirmar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.sage,
                        ),
                        SizedBox(width: 10),
                        Text('Confirmar orçamento'),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
          Obx(
            () => IconButton(
              tooltip: 'Salvar orçamento',
              onPressed: controller.salvando.value ||
                      controller.processando.value
                  ? null
                  : controller.salvarOrcamento,
              icon: controller.salvando.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: Obx(() {
        if (controller.carregando.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.ouro),
          );
        }

        final orcamento = controller.orcamento.value;

        if (orcamento == null) {
          return const _EstadoVazio(
            icone: Icons.receipt_long_outlined,
            titulo: 'Orçamento não encontrado',
            descricao: 'Não foi possível carregar este orçamento.',
          );
        }

        return RefreshIndicator(
          color: AppColors.ouro,
          onRefresh: controller.carregarOrcamento,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: [
              _buildResumoOrcamento(orcamento),
              const SizedBox(height: 16),
              const _HistoricoOrcamentoSection(),
              const SizedBox(height: 16),
              OrcamentoAcompanhamentoSection(controller: controller),
              const SizedBox(height: 18),
              _buildSecaoProdutos(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResumoOrcamento(Orcamento orcamento) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orcamento.titulo,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.cliente.value?.nome ??
                          'Cliente não informado',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.texto.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: orcamento.status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ResumoItem(
                  icone: Icons.people_alt_outlined,
                  titulo: 'Convidados',
                  valor: '${orcamento.convidados}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResumoItem(
                  icone: Icons.shopping_basket_outlined,
                  titulo: 'Produtos',
                  valor: '${controller.itens.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final totais = controller.totais;
            final compraPeloBufe =
                controller.orcamento.value?.ingredientesCompradosPeloBufe ??
                    true;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (compraPeloBufe) ...[
                    _LinhaTotal(
                      titulo: 'Supermercado',
                      valor: controller.formatarCentavos(
                        totais.supermercadoCentavos,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _LinhaTotal(
                      titulo: 'Combustível e tempo (20%)',
                      valor: controller.formatarCentavos(
                        totais.combustivelETempoCentavos,
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                  _LinhaTotal(
                    titulo: 'Serviços',
                    valor: controller.formatarCentavos(
                      totais.servicosCentavos,
                    ),
                  ),
                  if (totais.descontoCentavos > 0) ...[
                    const SizedBox(height: 7),
                    _LinhaTotal(
                      titulo: 'Desconto',
                      valor:
                          '- ${controller.formatarCentavos(totais.descontoCentavos)}',
                      corValor: AppColors.roseGold,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 9),
                    child: Divider(height: 1),
                  ),
                  _LinhaTotal(
                    titulo: 'Total estimado',
                    valor: controller.formatarCentavos(
                      totais.totalCentavos,
                    ),
                    destaque: true,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Obx(() {
            final aprovado = controller.aprovado;
            final ocupado = controller.processando.value;

            if (aprovado) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: ocupado ? null : controller.reabrirOrcamento,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Reabrir para editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.roseGold,
                    side: BorderSide(
                      color: AppColors.roseGold.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              );
            }

            if (controller.perdido) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      ocupado ? null : controller.reabrirParaNegociacao,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reabrir para negociação'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.roseGold,
                    side: BorderSide(
                      color: AppColors.roseGold.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: ocupado ? null : controller.confirmarOrcamento,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Confirmar orçamento'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sage,
                  side: BorderSide(
                    color: AppColors.sage.withValues(alpha: 0.55),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecaoProdutos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Produtos do orçamento',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
            ),
            Obx(
              () => Text(
                '${controller.itens.length} itens',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.texto.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Adicione produtos manualmente ou utilize uma receita cadastrada.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.texto.withValues(alpha: 0.58),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.itens.isEmpty) {
            return const _EstadoVazio(
              icone: Icons.shopping_basket_outlined,
              titulo: 'Nenhum produto adicionado',
              descricao:
                  'Adicione um produto manualmente ou escolha uma receita.',
            );
          }

          final bloqueado = !controller.podeEditar;

          return Column(
            children: [
              for (final item in controller.itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ItemProdutoCard(
                    item: item,
                    bloqueado: bloqueado,
                    onEditar: () => controller.editarItem(item),
                    onExcluir: () => _confirmarExclusao(item),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _confirmarExclusao(OrcamentoIten item) async {
    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(
          'O produto "${item.nome}" será removido deste orçamento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracota,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await controller.excluirItem(item.id);
    }
  }
}

class _ItemProdutoCard extends StatelessWidget {
  const _ItemProdutoCard({
    required this.item,
    required this.bloqueado,
    required this.onEditar,
    required this.onExcluir,
  });

  final OrcamentoIten item;
  final bool bloqueado;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final veioDeReceita =
        item.receitaId != null && item.receitaNome?.trim().isNotEmpty == true;

    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: bloqueado ? null : onEditar,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.sombraSutil,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: veioDeReceita
                      ? AppColors.champagne
                      : AppColors.fundo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  veioDeReceita
                      ? Icons.restaurant_menu_rounded
                      : Icons.shopping_basket_outlined,
                  color: veioDeReceita
                      ? AppColors.roseGold
                      : AppColors.texto.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _QuantidadeProduto(item: item),
                    if (veioDeReceita) ...[
                      const SizedBox(height: 8),
                      _EtiquetaReceita(nomeReceita: item.receitaNome!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (bloqueado)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.texto.withValues(alpha: 0.35),
                  ),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'Opções',
                  onSelected: (valor) {
                    if (valor == 'editar') onEditar();
                    if (valor == 'excluir') onExcluir();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantidadeProduto extends StatelessWidget {
  const _QuantidadeProduto({required this.item});

  final OrcamentoIten item;

  @override
  Widget build(BuildContext context) {
    final unidadeOriginal = item.unidade?.trim() ?? '';

    return Text(
      _formatarQuantidade(
        quantidadeMilesimos: item.quantidadeMilesimos,
        unidade: unidadeOriginal,
      ),
      style: TextStyle(
        fontSize: 13,
        color: AppColors.texto.withValues(alpha: 0.68),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatarQuantidade({
    required int quantidadeMilesimos,
    required String unidade,
  }) {
    final valor = quantidadeMilesimos / 1000;
    final unidadeNormalizada = unidade.toLowerCase().trim();

    if (unidadeNormalizada == 'g' &&
        valor >= 1000 &&
        valor % 1000 == 0) {
      return '${(valor / 1000).toInt()} kg';
    }

    if (unidadeNormalizada == 'ml' &&
        valor >= 1000 &&
        valor % 1000 == 0) {
      return '${(valor / 1000).toInt()} l';
    }

    final quantidade = _formatarNumero(valor);

    if (unidade.isEmpty) return quantidade;
    return '$quantidade $unidade';
  }

  String _formatarNumero(double valor) {
    if (valor == valor.truncateToDouble()) {
      return valor.toInt().toString();
    }

    return valor
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }
}

class _EtiquetaReceita extends StatelessWidget {
  const _EtiquetaReceita({required this.nomeReceita});

  final String nomeReceita;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.champagne,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 13,
            color: AppColors.roseGold,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Receita: $nomeReceita',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.roseGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  const _ResumoItem({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  final IconData icone;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.fundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icone, size: 21, color: AppColors.roseGold),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.texto.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final statusNormalizado = status.toLowerCase();
    final aprovado = statusNormalizado == 'aprovado';
    final enviado = statusNormalizado == 'enviado';
    final perdido = statusNormalizado == 'perdido';
    final recusado = statusNormalizado == 'recusado';

    final cor = aprovado
        ? AppColors.sage
        : perdido || recusado
            ? AppColors.terracota
            : enviado
                ? AppColors.roseGold
                : AppColors.pessego;

    final texto = aprovado
        ? 'Aprovado'
        : perdido
            ? 'Perdido'
            : recusado
                ? 'Recusado'
                : enviado
                    ? 'Enviado'
                    : 'Pendente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cor,
        ),
      ),
    );
  }
}

class _LinhaTotal extends StatelessWidget {
  const _LinhaTotal({
    required this.titulo,
    required this.valor,
    this.destaque = false,
    this.corValor,
  });

  final String titulo;
  final String valor;
  final bool destaque;
  final Color? corValor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: destaque ? 14 : 12,
              fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.texto.withValues(
                alpha: destaque ? 1 : 0.68,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          valor,
          style: TextStyle(
            fontSize: destaque ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: corValor ?? AppColors.texto,
          ),
        ),
      ],
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Column(
        children: [
          Icon(
            icone,
            size: 42,
            color: AppColors.roseGold.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.texto.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricoOrcamentoSection extends GetView<OrcamentoDetalheController> {
  const _HistoricoOrcamentoSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final registros = controller.historico.toList();
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, color: AppColors.roseGold),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Histórico de alterações',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                ),
                Text(
                  '${registros.length}',
                  style: TextStyle(
                    color: AppColors.texto.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (registros.isEmpty)
              Text(
                'As alterações e aprovações deste orçamento aparecerão aqui.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.texto.withValues(alpha: 0.58),
                ),
              )
            else
              for (var index = 0; index < registros.length; index++) ...[
                if (index > 0) const Divider(height: 18),
                _HistoricoOrcamentoTile(registro: registros[index]),
              ],
          ],
        ),
      );
    });
  }
}

class _HistoricoOrcamentoTile extends StatelessWidget {
  const _HistoricoOrcamentoTile({required this.registro});

  final OrcamentoHistorico registro;

  @override
  Widget build(BuildContext context) {
    String dois(int valor) => valor.toString().padLeft(2, '0');
    final data = registro.ocorridoEm;
    final quando = '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
    final anterior = registro.valorAnterior?.trim();
    final novo = registro.valorNovo?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.champagne.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            registro.campo == 'Status'
                ? Icons.verified_outlined
                : Icons.edit_note_rounded,
            size: 19,
            color: AppColors.roseGold,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${registro.tipo} · ${registro.campo}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$quando · ${registro.autor}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.texto.withValues(alpha: 0.55),
                ),
              ),
              if ((anterior?.isNotEmpty ?? false) || (novo?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 6),
                if (anterior?.isNotEmpty ?? false)
                  Text(
                    'Antes: $anterior',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.texto.withValues(alpha: 0.62),
                    ),
                  ),
                if (novo?.isNotEmpty ?? false)
                  Text(
                    'Depois: $novo',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.texto,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

