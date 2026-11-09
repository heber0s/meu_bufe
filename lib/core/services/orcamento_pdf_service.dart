import 'dart:io';

import 'package:get/get.dart' hide Value;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/database/app_database.dart';
import '../../modules/orcamentos/orcamento_totais.dart';
import '../utils/formatters.dart';
import 'empresa_service.dart';

class OrcamentoPdfService {
  static final _ouro = PdfColor.fromHex('#D4AF37');
  static final _roseGold = PdfColor.fromHex('#B76E79');
  static final _texto = PdfColor.fromHex('#2C3E50');
  static final _champagne = PdfColor.fromHex('#F7E7CE');
  static final _suave = PdfColor.fromHex('#FAF8F5');

  static String _calculoDoItem(OrcamentoIten item, int convidados) {
    final preco = item.precoCentavos;

    switch (item.tipoCobranca) {
      case 'porConvidado':
        return '${formatarMoeda(preco)} × $convidados convidados';
      case 'porUnidade':
        return '${formatarMoeda(preco)} × ${item.quantidade} unidades';
      case 'geral':
      default:
        return '${formatarMoeda(preco)} · valor geral';
    }
  }

  /// Gera o PDF, grava em arquivo temporário e devolve o arquivo.
  static Future<File> gerar({
    required Orcamento orcamento,
    required Cliente? cliente,
    required List<OrcamentoIten> itens,
  }) async {
    final empresa = Get.find<EmpresaService>();
    final nomeEmpresa = empresa.nome.value;
    final contatoEmpresa = empresa.contatoLinha;
    final validadeDias = empresa.validadeDias.value;

    final ingredientes = itens
        .where((item) => item.categoria == 'ingrediente')
        .toList();

    final servicos = itens
        .where((item) => item.categoria != 'ingrediente')
        .toList();

    // Usa a regra financeira centralizada, compartilhada com o restante do app.
    final totais = OrcamentoTotais.calcular(
      orcamento: orcamento,
      itens: itens,
    );

    // Logo da empresa, caso esteja configurada e seja compatível com o PDF.
    final bytesLogo = await empresa.logoParaPdf();
    pw.MemoryImage? logo;

    if (bytesLogo != null) {
      try {
        logo = pw.MemoryImage(bytesLogo);
      } catch (_) {
        logo = null;
      }
    }

    final titulos = pw.Font.timesBold();
    final corpo = pw.Font.helvetica();
    final corpoNegrito = pw.Font.helveticaBold();

    final dataEmissao = DateTime.now();
    final dataEvento = orcamento.dataEvento;
    final hora = '${dataEvento.hour.toString().padLeft(2, '0')}:'
        '${dataEvento.minute.toString().padLeft(2, '0')}';

    pw.TextStyle estilo(
      double tamanho, {
      pw.Font? fonte,
      PdfColor? cor,
      double? espaco,
    }) {
      return pw.TextStyle(
        font: fonte ?? corpo,
        fontSize: tamanho,
        color: cor ?? _texto,
        letterSpacing: espaco,
      );
    }

    pw.Widget secao(String titulo) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
        child: pw.Text(
          titulo.toUpperCase(),
          style: estilo(
            9,
            fonte: corpoNegrito,
            cor: _roseGold,
            espaco: 1.6,
          ),
        ),
      );
    }

    pw.Widget linha(String rotulo, String valor) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 80,
              child: pw.Text(
                rotulo,
                style: estilo(10, cor: PdfColors.grey600),
              ),
            ),
            pw.Expanded(
              child: pw.Text(valor, style: estilo(10.5)),
            ),
          ],
        ),
      );
    }

    pw.Widget celula(
      String texto, {
      bool negrito = false,
      pw.TextAlign? alinhar,
      double tamanho = 10,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Text(
          texto,
          textAlign: alinhar,
          style: estilo(
            tamanho,
            fonte: negrito ? corpoNegrito : corpo,
          ),
        ),
      );
    }

    pw.Widget linhaTotal(
      String rotulo,
      String valor, {
      bool destaque = false,
      PdfColor? cor,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              rotulo,
              style: estilo(
                destaque ? 12 : 10,
                fonte: destaque ? corpoNegrito : corpo,
              ),
            ),
            pw.Text(
              valor,
              style: estilo(
                destaque ? 16 : 10.5,
                fonte: destaque ? titulos : corpoNegrito,
                cor: destaque ? _ouro : cor,
              ),
            ),
          ],
        ),
      );
    }

    pw.TableRow cabecalhoTabela(List<String> titulosColunas) {
      return pw.TableRow(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: _ouro, width: 1),
          ),
        ),
        children: [
          for (final titulo in titulosColunas)
            celula(
              titulo,
              negrito: true,
              tamanho: 9,
              alinhar:
                  titulo == 'Total' ? pw.TextAlign.right : pw.TextAlign.left,
            ),
        ],
      );
    }

    final doc = pw.Document(
      title: 'Orçamento - ${orcamento.titulo}',
      author: nomeEmpresa,
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 40),
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _suave),
          ),
        ),
        footer: (contexto) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                contatoEmpresa,
                style: estilo(8, cor: PdfColors.grey600),
              ),
              pw.Text(
                'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
                style: estilo(8, cor: PdfColors.grey600),
              ),
            ],
          ),
        ),
        build: (contexto) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 22),
            decoration: pw.BoxDecoration(
              color: _champagne,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              children: [
                if (logo != null) ...[
                  pw.SizedBox(
                    height: 56,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(height: 10),
                ],
                pw.Text(nomeEmpresa, style: estilo(24, fonte: titulos)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'PROPOSTA DE ORÇAMENTO',
                  style: estilo(
                    9,
                    fonte: corpoNegrito,
                    cor: _roseGold,
                    espaco: 2.5,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(orcamento.titulo, style: estilo(20, fonte: titulos)),
          pw.SizedBox(height: 5),
          pw.Text(
            'Emitido em ${dataCompleta(dataEmissao)}',
            style: estilo(9, cor: PdfColors.grey600),
          ),

          secao('Cliente'),
          linha('Nome', cliente?.nome ?? '-'),
          if (cliente?.telefone != null)
            linha('Telefone', cliente!.telefone!),
          if (cliente?.email != null) linha('E-mail', cliente!.email!),

          secao('Evento'),
          linha('Data', '${dataCompleta(dataEvento)} às $hora'),
          if (orcamento.local != null) linha('Local', orcamento.local!),
          linha('Convidados', '${orcamento.convidados}'),

          // Serviços podem exibir preço e cálculo. Ingredientes não aparecem
          // nesta tabela, evitando a exibição de seus valores individuais.
          secao('Serviços'),
          if (servicos.isEmpty)
            pw.Text(
              'Nenhum serviço incluído.',
              style: estilo(10, cor: PdfColors.grey600),
            )
          else
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(4.2),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(2.4),
              },
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
              ),
              children: [
                cabecalhoTabela(['Serviço', 'Cálculo', 'Total']),
                for (final item in servicos)
                  pw.TableRow(
                    children: [
                      celula(item.nome, negrito: true),
                      celula(
                        _calculoDoItem(item, orcamento.convidados),
                        tamanho: 9,
                      ),
                      celula(
                        formatarMoeda(
                          OrcamentoTotais.totalDoItem(
                            item,
                            orcamento.convidados,
                          ),
                        ),
                        negrito: true,
                        alinhar: pw.TextAlign.right,
                      ),
                    ],
                  ),
              ],
            ),

          // A lista de compras contém nomes e quantidades, nunca preços.
          if (ingredientes.isNotEmpty) ...[
            secao('Lista de compras'),
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(2),
              },
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
              ),
              children: [
                cabecalhoTabela(['Ingrediente', 'Quantidade']),
                for (final ingrediente in ingredientes)
                  pw.TableRow(
                    children: [
                      celula(ingrediente.nome, negrito: true),
                      celula(
                        _descricaoQuantidade(ingrediente),
                        tamanho: 9,
                      ),
                    ],
                  ),
              ],
            ),
          ],

          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 260,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: _champagne, width: 1),
              ),
              child: pw.Column(
                children: [
                  if (orcamento.ingredientesCompradosPeloBufe) ...[
                    linhaTotal(
                      'Supermercado',
                      formatarMoeda(totais.supermercadoCentavos),
                    ),
                    linhaTotal(
                      'Combustível e tempo (20%)',
                      formatarMoeda(totais.combustivelETempoCentavos),
                    ),
                  ],
                  linhaTotal(
                    'Serviços',
                    formatarMoeda(totais.servicosCentavos),
                  ),
                  if (totais.descontoCentavos > 0)
                    linhaTotal(
                      'Desconto',
                      '- ${formatarMoeda(totais.descontoCentavos)}',
                      cor: _roseGold,
                    ),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                  linhaTotal(
                    'Total',
                    formatarMoeda(totais.totalCentavos),
                    destaque: true,
                  ),
                ],
              ),
            ),
          ),

          if (orcamento.observacoes != null) ...[
            secao('Observações'),
            pw.Text(
              orcamento.observacoes!,
              style: estilo(10).copyWith(lineSpacing: 3),
            ),
          ],

          pw.SizedBox(height: 22),
          pw.Text(
            'Proposta válida por $validadeDias dias a partir da data de emissão.',
            style: estilo(9, cor: PdfColors.grey600),
          ),
        ],
      ),
    );

    final diretorio = await getTemporaryDirectory();
    final slug = orcamento.titulo
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    final arquivo = File(
      '${diretorio.path}/orcamento_${orcamento.id}_$slug.pdf',
    );

    await arquivo.writeAsBytes(await doc.save(), flush: true);
    return arquivo;
  }

  static String _descricaoQuantidade(OrcamentoIten item) {
    final partes = <String>[];

    if (item.quantidadeMilesimos != 1000) {
      partes.add(_formatarQuantidade(item.quantidadeMilesimos / 1000));
    }

    final unidade = item.unidade?.trim();
    if (unidade != null && unidade.isNotEmpty) {
      partes.add(unidade);
    }

    return partes.isEmpty ? '—' : partes.join(' ');
  }

  static String _formatarQuantidade(double quantidade) {
    if (quantidade == quantidade.roundToDouble()) {
      return quantidade.toInt().toString();
    }

    return quantidade
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }
}