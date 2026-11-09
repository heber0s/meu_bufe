import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/backup_service.dart';
import '../../core/services/empresa_service.dart';

class AjustesController extends GetxController {
  final _empresa = Get.find<EmpresaService>();
  final _picker = ImagePicker();

  // ---- estado de carregamento
  final fazendoBackup = false.obs;
  final restaurando = false.obs;
  final salvandoEmpresa = false.obs;
  final salvandoLogo = false.obs;

  // ---- campos do formulário "Dados do bufê"
  final nomeCtrl = TextEditingController();
  final telefoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final validadeCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _preencherCampos();

    // Se os dados mudarem por fora (ex.: backup restaurado), os campos
    // acompanham. Os workers são descartados junto com o controller.
    ever(_empresa.nome, (_) => _preencherCampos());
    ever(_empresa.telefone, (_) => _preencherCampos());
    ever(_empresa.email, (_) => _preencherCampos());
    ever(_empresa.validadeDias, (_) => _preencherCampos());
  }

  @override
  void onClose() {
    nomeCtrl.dispose();
    telefoneCtrl.dispose();
    emailCtrl.dispose();
    validadeCtrl.dispose();
    super.onClose();
  }

  /// Só altera o campo se o texto for diferente, para não mexer no cursor
  void _preencherCampos() {
    void definir(TextEditingController c, String valor) {
      if (c.text != valor) c.text = valor;
    }

    definir(nomeCtrl, _empresa.nome.value);
    definir(telefoneCtrl, _empresa.telefone.value);
    definir(emailCtrl, _empresa.email.value);
    definir(validadeCtrl, '${_empresa.validadeDias.value}');
  }

  // ===================== Dados do bufê =====================

  Future<void> salvarEmpresa() async {
    if (salvandoEmpresa.value) return;

    final nome = nomeCtrl.text.trim();
    final validade = int.tryParse(validadeCtrl.text.trim());

    if (nome.isEmpty) {
      Get.snackbar('Dados incompletos', 'Informe o nome do bufê.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (validade == null || validade < 1 || validade > 365) {
      Get.snackbar('Validade inválida', 'Use um valor entre 1 e 365 dias.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    salvandoEmpresa.value = true;
    try {
      await _empresa.salvarDados(
        nome: nome,
        telefone: telefoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        validadeDias: validade,
      );
      Get.snackbar(
          'Dados salvos', 'O próximo PDF já sairá com essas informações.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Não foi possível salvar', '$e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      salvandoEmpresa.value = false;
    }
  }

  // ===================== Logo =====================

  Future<void> escolherLogo() async {
    if (salvandoLogo.value) return;
    try {
      // maxWidth/maxHeight reduzem a imagem antes de ela ir para o banco
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (img == null) return; // usuário cancelou

      salvandoLogo.value = true;
      await _empresa.salvarLogo(await img.readAsBytes());
      Get.snackbar('Logo salvo', 'O próximo PDF já sairá com o seu logo.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Não foi possível salvar o logo', '$e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      salvandoLogo.value = false;
    }
  }

  Future<void> usarLogoPadrao() async {
    try {
      await _empresa.removerLogo();
      Get.snackbar('Logo padrão', 'O PDF voltará a usar o logo do app.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Não foi possível restaurar o logo', '$e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ===================== Backup e restauração =====================

  Future<void> fazerBackup() async {
    if (fazendoBackup.value) return;
    fazendoBackup.value = true;
    try {
      final arquivo = await BackupService.gerarArquivo();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(arquivo.path, mimeType: 'application/octet-stream')],
          subject: 'Backup do Bufê',
          text: 'Backup dos orçamentos, clientes e agenda.',
        ),
      );
    } catch (e) {
      Get.snackbar('Não foi possível gerar o backup', '$e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      fazendoBackup.value = false;
    }
  }

  Future<void> restaurar() async {
    if (restaurando.value) return;

    final confirmou = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Restaurar backup?'),
        content: const Text(
          'Todos os dados atuais (orçamentos, clientes e agenda) serão '
          'substituídos pelos do arquivo escolhido. Uma cópia do estado '
          'atual é guardada antes, por segurança.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB5694A)),
            child: const Text('Escolher arquivo'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    // FileType.any: a extensão .db não é filtrável de forma confiável no Android
    final escolhido = await FilePicker.pickFile(type: FileType.any);
    final caminho = escolhido?.path;
    if (caminho == null) return;

    restaurando.value = true;
    try {
      await BackupService.restaurar(caminho);
      Get.snackbar('Backup restaurado', 'Seus dados foram recuperados.',
          snackPosition: SnackPosition.BOTTOM);
    } on BackupException catch (e) {
      Get.snackbar('Não foi possível restaurar', e.mensagem,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Não foi possível restaurar', '$e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      restaurando.value = false;
    }
  }
}