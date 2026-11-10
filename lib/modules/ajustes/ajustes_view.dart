import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/services/empresa_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import 'ajustes_controller.dart';

class AjustesView extends GetView<AjustesController> {
  const AjustesView({super.key});

  // Getter (e não campo), porque o construtor é const
  EmpresaService get _empresa => Get.find<EmpresaService>();

  @override
  Widget build(BuildContext context) {
    final titulo = Theme.of(context).textTheme.titleLarge;
    final suave = TextStyle(
      height: 1.4,
      color: AppColors.texto.withValues(alpha: 0.6),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ================= Dados do bufê =================
          Text('Dados do bufê', style: titulo),
          const SizedBox(height: 6),
          Text(
            'Aparecem no cabeçalho e no rodapé do PDF enviado aos clientes.',
            style: suave,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.superficie,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.sombraSutil,
            ),
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 18),
                TextField(
                  controller: controller.nomeCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nome do bufê'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.telefoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [const _TelefoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(11) 99999-9999',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.validadeCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Validade da proposta',
                    suffixText: 'dias',
                  ),
                ),
                const SizedBox(height: 18),
                // O controller controla o estado; só o botão reage
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: controller.salvandoEmpresa.value
                            ? null
                            : controller.salvarEmpresa,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ouro,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: controller.salvandoEmpresa.value
                              ? const SizedBox(
                                  key: ValueKey('salvando'),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Salvar dados',
                                  key: ValueKey('texto')),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ================= Seus dados (backup) =================
          Text('Seus dados', style: titulo),
          const SizedBox(height: 6),
          Text(
            'Tudo fica salvo apenas neste aparelho. Faça backups com '
            'frequência e guarde o arquivo em um lugar seguro, pois ele '
            'contém os dados dos seus clientes.',
            style: suave,
          ),
          const SizedBox(height: 20),
          _CardAcao(
            icone: Icons.cloud_upload_outlined,
            titulo: 'Fazer backup',
            descricao: 'Gera um arquivo e abre o compartilhamento para você '
                'enviar ao Drive, WhatsApp ou e-mail.',
            ocupado: controller.fazendoBackup,
            onTap: controller.fazerBackup,
          ),
          const SizedBox(height: 14),
          _CardAcao(
            icone: Icons.settings_backup_restore_rounded,
            titulo: 'Restaurar backup',
            descricao: 'Substitui os dados atuais pelos de um arquivo de '
                'backup feito anteriormente.',
            ocupado: controller.restaurando,
            onTap: controller.restaurar,
          ),
        ],
      ),
    );
  }

  /// Logo atual (do usuário ou padrão do app) e botões para trocá-lo
  Widget _buildLogo() {
    return Obx(() {
      final proprio = _empresa.logoPersonalizado.value;
      final salvando = controller.salvandoLogo.value;

      return Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.champagne.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: proprio != null
                  ? Image.memory(
                      proprio,
                      key: const ValueKey('proprio'),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    )
                  : Image.asset(
                      EmpresaService.logoPadraoAsset,
                      key: const ValueKey('padrao'),
                      fit: BoxFit.contain,
                      // Se o asset não estiver declarado no pubspec
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.storefront_outlined,
                        size: 40,
                        color: AppColors.roseGold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            proprio != null ? 'Logo personalizado' : 'Logo padrão do app',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.texto.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: salvando ? null : controller.escolherLogo,
                icon: salvando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ouro,
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 18),
                label: Text(proprio != null ? 'Trocar logo' : 'Escolher logo'),
              ),
              if (proprio != null)
                TextButton(
                  onPressed: salvando ? null : controller.usarLogoPadrao,
                  child: const Text('Usar logo padrão'),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _CardAcao extends StatelessWidget {
  const _CardAcao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.ocupado,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final RxBool ocupado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.sombraSutil,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.champagne,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icone, color: AppColors.roseGold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.texto.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: ocupado.value
                          ? const SizedBox(
                              key: ValueKey('carregando'),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.ouro,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              key: ValueKey('seta'),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TelefoneInputFormatter extends TextInputFormatter {
  const _TelefoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final cursorOffset = newValue.selection.extentOffset
        .clamp(0, newValue.text.length)
        .toInt();
    var digitsBeforeCursor = newValue.text
        .substring(0, cursorOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Ao apagar um separador automático, remove também o dígito adjacente.
    // Isso permite corrigir o DDD sem o cursor ficar preso na máscara.
    if (newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length) {
      var prefixLength = 0;
      while (prefixLength < oldValue.text.length &&
          prefixLength < newValue.text.length &&
          oldValue.text[prefixLength] == newValue.text[prefixLength]) {
        prefixLength++;
      }

      var suffixLength = 0;
      while (suffixLength < oldValue.text.length - prefixLength &&
          suffixLength < newValue.text.length - prefixLength &&
          oldValue.text[oldValue.text.length - 1 - suffixLength] ==
              newValue.text[newValue.text.length - 1 - suffixLength]) {
        suffixLength++;
      }

      final removido = oldValue.text.substring(
        prefixLength,
        oldValue.text.length - suffixLength,
      );

      if (removido.isNotEmpty && !RegExp(r'\d').hasMatch(removido)) {
        final digitsBeforeDeletion = oldValue.text
            .substring(0, prefixLength)
            .replaceAll(RegExp(r'\D'), '')
            .length;
        final indexToRemove = digitsBeforeDeletion > 0
            ? digitsBeforeDeletion - 1
            : 0;

        if (digits.isNotEmpty && indexToRemove < digits.length) {
          digits = digits.replaceRange(indexToRemove, indexToRemove + 1, '');
          digitsBeforeCursor = indexToRemove;
        }
      }
    }

    if (digits.length > 11) digits = digits.substring(0, 11);
    if (digitsBeforeCursor > digits.length) {
      digitsBeforeCursor = digits.length;
    }

    final formatted = _formatarTelefone(digits);
    final offset = _cursorOffset(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static String _formatarTelefone(String digitos) {
    final numero = digitos.length > 11 ? digitos.substring(0, 11) : digitos;
    if (numero.isEmpty) return '';

    if (numero.length <= 2) {
      return numero.length == 2 ? '($numero) ' : '($numero';
    }

    final ddd = numero.substring(0, 2);
    final restante = numero.substring(2);
    final tamanhoPrefixo = numero.length > 10 ? 5 : 4;
    final base = '($ddd) ';

    if (restante.length <= tamanhoPrefixo) {
      return '$base$restante';
    }

    return '$base${restante.substring(0, tamanhoPrefixo)}-'
        '${restante.substring(tamanhoPrefixo)}';
  }

  int _cursorOffset(String text, int digitsBeforeCursor) {
    if (digitsBeforeCursor <= 0) return 0;
    if (digitsBeforeCursor == text.replaceAll(RegExp(r'\D'), '').length) {
      return text.length;
    }

    var digitsFound = 0;
    for (var index = 0; index < text.length; index++) {
      if (RegExp(r'\d').hasMatch(text[index])) {
        digitsFound++;
        if (digitsFound == digitsBeforeCursor) return index + 1;
      }
    }
    return text.length;
  }
}
