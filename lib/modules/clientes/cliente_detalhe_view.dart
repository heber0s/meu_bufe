import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../routes/app_routes.dart';
import 'cliente_detalhe_controller.dart';

class ClienteDetalheView extends GetView<ClienteDetalheController> {
  const ClienteDetalheView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColors.fundo,
        body: Obx(() {
          if (controller.carregando.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.ouro,
                strokeWidth: 2,
              ),
            );
          }

          final cliente = controller.cliente.value;
          if (cliente == null) {
            return _EstadoClienteIndisponivel(
              aoVoltar: () => Get.back(),
              mensagem: controller.erro.value
                  ? 'Não foi possível carregar este cliente.'
                  : 'Este cliente não está mais disponível.',
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 24, 12),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Voltar',
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Perfil do cliente',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                  child: _CartaoCliente(
                    nome: cliente.nome,
                    telefone: cliente.telefone,
                    email: cliente.email,
                    onEditar: controller.editarCliente,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Resumo dos orçamentos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                  child: _ResumoOrcamentos(
                    quantidade: controller.quantidadeOrcamentos,
                    aprovado: controller.totalAprovadoCentavos,
                    emAberto: controller.totalEmAbertoCentavos,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Histórico de orçamentos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${controller.quantidadeOrcamentos}',
                        style: TextStyle(
                          color: AppColors.texto.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.orcamentos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _HistoricoVazio(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                  sliver: SliverList.separated(
                    itemCount: controller.orcamentos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _OrcamentoClienteCard(
                      resumo: controller.orcamentos[index],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  const _CartaoCliente({
    required this.nome,
    required this.telefone,
    required this.email,
    required this.onEditar,
  });

  final String nome;
  final String? telefone;
  final String? email;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.champagne,
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: AppColors.roseGold,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: AppColors.texto,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                if (telefone != null && telefone!.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  _LinhaContato(
                    icone: Icons.phone_outlined,
                    texto: telefone!,
                  ),
                ],
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  _LinhaContato(
                    icone: Icons.email_outlined,
                    texto: email!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Editar dados do cliente',
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.roseGold,
          ),
        ],
      ),
    );
  }

  static String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final lista = partes.toList();
    if (lista.isEmpty) return '?';
    if (lista.length == 1) return lista.first.substring(0, 1).toUpperCase();
    return '${lista.first[0]}${lista.last[0]}'.toUpperCase();
  }
}

class _LinhaContato extends StatelessWidget {
  const _LinhaContato({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 15, color: AppColors.roseGold),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.texto.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResumoOrcamentos extends StatelessWidget {
  const _ResumoOrcamentos({
    required this.quantidade,
    required this.aprovado,
    required this.emAberto,
  });

  final int quantidade;
  final int aprovado;
  final int emAberto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _IndicadorResumo(
                titulo: 'Orçamentos',
                valor: '$quantidade',
                icone: Icons.description_outlined,
                cor: AppColors.roseGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _IndicadorResumo(
                titulo: 'Aprovados',
                valor: ClienteDetalheController.formatarMoeda(aprovado),
                icone: Icons.check_circle_outline_rounded,
                cor: AppColors.aprovado,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _IndicadorResumo(
          titulo: 'Em aberto',
          valor: ClienteDetalheController.formatarMoeda(emAberto),
          icone: Icons.hourglass_empty_rounded,
          cor: AppColors.pendente,
          horizontal: true,
        ),
      ],
    );
  }
}

class _IndicadorResumo extends StatelessWidget {
  const _IndicadorResumo({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.horizontal = false,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.sombraSutil,
      ),
      child: horizontal
          ? Row(
              children: [
                Icon(icone, color: cor, size: 20),
                const SizedBox(width: 10),
                Text(titulo, style: TextStyle(color: AppColors.texto.withValues(alpha: 0.62))),
                const Spacer(),
                Flexible(
                  child: Text(
                    valor,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.texto),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, color: cor, size: 19),
                const SizedBox(height: 10),
                Text(
                  titulo,
                  style: TextStyle(
                    color: AppColors.texto.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.texto,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}

class _OrcamentoClienteCard extends StatelessWidget {
  const _OrcamentoClienteCard({required this.resumo});

  final OrcamentoClienteResumo resumo;

  @override
  Widget build(BuildContext context) {
    final orcamento = resumo.orcamento;
    final status = orcamento.status.toLowerCase();
    final cor = status == 'aprovado'
        ? AppColors.aprovado
        : status == 'perdido'
            ? AppColors.roseGold
            : AppColors.pendente;

    return PressableScale(
      onTap: () => Get.toNamed(Routes.detalhe(orcamento.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.sombraSutil,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.champagne,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.event_note_outlined,
                color: AppColors.roseGold,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orcamento.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Evento: ${ClienteDetalheController.formatarData(orcamento.dataEvento)}',
                    style: TextStyle(
                      color: AppColors.texto.withValues(alpha: 0.58),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          ClienteDetalheController.rotuloStatus(orcamento.status),
                          style: TextStyle(
                            color: cor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        ClienteDetalheController.formatarMoeda(resumo.totalCentavos),
                        style: const TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.texto.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricoVazio extends StatelessWidget {
  const _HistoricoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, size: 36, color: AppColors.roseGold),
            const SizedBox(height: 12),
            Text('Ainda não há orçamentos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 5),
            Text(
              'Os orçamentos deste cliente aparecerão aqui.',
              style: TextStyle(color: AppColors.texto.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoClienteIndisponivel extends StatelessWidget {
  const _EstadoClienteIndisponivel({required this.aoVoltar, required this.mensagem});

  final VoidCallback aoVoltar;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_outlined, size: 42, color: AppColors.roseGold),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: aoVoltar, child: const Text('Voltar')),
          ],
        ),
      ),
    );
  }
}
