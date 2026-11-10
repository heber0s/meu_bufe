import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'relatorios_controller.dart';

enum FormatoRelatorioExportacao { pdf, csv }

class RelatoriosExportService {
  static const PdfColor _marinho = PdfColor(0.173, 0.243, 0.314);
  static const PdfColor _ouro = PdfColor(0.831, 0.686, 0.216);
  static const PdfColor _creme = PdfColor(0.980, 0.973, 0.961);
  static const PdfColor _borda = PdfColor(0.89, 0.88, 0.85);

  static final DateFormat _data = DateFormat('dd/MM/yyyy');
  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final NumberFormat _numero =
      NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);
  static final NumberFormat _percentual = NumberFormat.percentPattern('pt_BR');

  Future<void> compartilharPdf(RelatoriosController controller) async {
    final bytes = await _criarPdf(controller);
    final nome = 'relatorio_bufe_${_carimbo()}.pdf';
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: nome)],
        subject: 'Relatório de orçamentos — ${controller.periodoLabel}',
        text: 'Relatório de orçamentos: ${controller.periodoLabel}.',
      ),
    );
  }

  Future<void> compartilharCsv(RelatoriosController controller) async {
    final bytes = _criarCsv(controller);
    final nome = 'relatorio_bufe_${_carimbo()}.csv';
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'text/csv',
            name: nome,
          ),
        ],
        subject: 'Relatório de orçamentos — ${controller.periodoLabel}',
        text: 'Relatório de orçamentos: ${controller.periodoLabel}.',
      ),
    );
  }

  Future<Uint8List> _criarPdf(RelatoriosController controller) async {
    final documento = pw.Document(
      title: 'Relatório de orçamentos',
      author: 'Meu Bufê',
      subject: 'Indicadores de ${controller.periodoLabel}',
    );
    final registros = controller.orcamentosFiltrados;
    final geradoEm = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    documento.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 40),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _creme),
          ),
        ),
        footer: (contexto) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _borda, width: 0.6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Meu Bufê • Relatório de orçamentos',
                style: const pw.TextStyle(fontSize: 8, color: _marinho),
              ),
              pw.Text(
                'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: _marinho),
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 14),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _ouro, width: 1.5)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RELATÓRIO DE ORÇAMENTOS',
                      style: pw.TextStyle(
                        fontSize: 19,
                        fontWeight: pw.FontWeight.bold,
                        color: _marinho,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Período: ${controller.periodoLabel}',
                      style: const pw.TextStyle(fontSize: 10, color: _marinho),
                    ),
                  ],
                ),
                pw.Text(
                  'Gerado em $geradoEm',
                  style: const pw.TextStyle(fontSize: 8, color: _marinho),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _tituloSecao('Resumo do período'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Indicador', 'Quantidade', 'Valor total'],
            data: [
              [
                'Todos os orçamentos',
                '${controller.quantidadeTotal}',
                _formatarMoeda(controller.valorTotalCentavos),
              ],
              [
                'Aprovados',
                '${controller.quantidadeAprovados}',
                _formatarMoeda(controller.valorAprovadoCentavos),
              ],
              [
                'Enviados',
                '${controller.quantidadeEnviados}',
                _formatarMoeda(controller.valorEnviadoCentavos),
              ],
              [
                'Pendentes',
                '${controller.quantidadePendentes}',
                _formatarMoeda(controller.valorPendenteCentavos),
              ],
              [
                'Perdidos/recusados',
                '${controller.quantidadePerdidos}',
                _formatarMoeda(controller.valorPerdidoCentavos),
              ],
            ],
            headerDecoration: const pw.BoxDecoration(color: _marinho),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9, color: _marinho),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            border: pw.TableBorder.all(color: _borda, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.4),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1.5),
            },
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor(0.969, 0.906, 0.808),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Conversão final: ${_percentual.format(controller.taxaConversao)} '
              '(${controller.quantidadeAprovados} aprovados de '
              '${controller.quantidadeConcluida} orçamentos concluídos).',
              style: pw.TextStyle(
                fontSize: 9,
                color: _marinho,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          _tituloSecao('Clientes em destaque'),
          pw.SizedBox(height: 8),
          if (controller.principaisClientes.isEmpty)
            pw.Text(
              'Não há orçamentos aprovados neste período.',
              style: const pw.TextStyle(fontSize: 9, color: _marinho),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const ['#', 'Cliente', 'Orçamentos aprovados', 'Valor'],
              data: controller.principaisClientes.asMap().entries.map((entry) => [
                '${entry.key + 1}',
                entry.value.nome,
                '${entry.value.quantidadeOrcamentos}',
                _formatarMoeda(entry.value.valorCentavos),
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: _marinho),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8, color: _marinho),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              border: pw.TableBorder.all(color: _borda, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(0.35),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.2),
              },
            ),
          pw.SizedBox(height: 18),
          _tituloSecao('Orçamentos do período'),
          pw.SizedBox(height: 8),
          if (registros.isEmpty)
            pw.Text(
              'Nenhum orçamento encontrado no período selecionado.',
              style: const pw.TextStyle(fontSize: 9, color: _marinho),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Evento', 'Cliente', 'Status', 'Convidados', 'Total'],
              data: registros.map((registro) => [
                _data.format(registro.orcamento.dataEvento),
                registro.cliente.nome,
                _statusLegivel(registro.orcamento.status),
                '${registro.orcamento.convidados}',
                _formatarMoeda(registro.totalCentavos),
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: _marinho),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 7.5, color: _marinho),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              border: pw.TableBorder.all(color: _borda, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.05),
                1: pw.FlexColumnWidth(2.2),
                2: pw.FlexColumnWidth(1.15),
                3: pw.FlexColumnWidth(0.8),
                4: pw.FlexColumnWidth(1.25),
              },
            ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Os valores representam os totais dos orçamentos, não pagamentos recebidos.',
            style: const pw.TextStyle(fontSize: 8, color: _marinho),
          ),
        ],
      ),
    );

    return documento.save();
  }

  Uint8List _criarCsv(RelatoriosController controller) {
    final linhas = <List<String>>[
      ['Relatório de orçamentos'],
      ['Período', controller.periodoLabel],
      ['Gerado em', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())],
      [],
      ['Indicador', 'Quantidade', 'Valor total (R\$)'],
      [
        'Todos os orçamentos',
        '${controller.quantidadeTotal}',
        _formatarNumero(controller.valorTotalCentavos),
      ],
      [
        'Aprovados',
        '${controller.quantidadeAprovados}',
        _formatarNumero(controller.valorAprovadoCentavos),
      ],
      [
        'Enviados',
        '${controller.quantidadeEnviados}',
        _formatarNumero(controller.valorEnviadoCentavos),
      ],
      [
        'Pendentes',
        '${controller.quantidadePendentes}',
        _formatarNumero(controller.valorPendenteCentavos),
      ],
      [
        'Perdidos/recusados',
        '${controller.quantidadePerdidos}',
        _formatarNumero(controller.valorPerdidoCentavos),
      ],
      [
        'Conversão final',
        _percentual.format(controller.taxaConversao),
        'Aprovados de orçamentos concluídos',
      ],
      [],
      ['Clientes em destaque'],
      ['Posição', 'Cliente', 'Orçamentos aprovados', 'Valor aprovado (R\$)'],
      ...controller.principaisClientes.asMap().entries.map((entry) => [
            '${entry.key + 1}',
            _protegerFormula(entry.value.nome),
            '${entry.value.quantidadeOrcamentos}',
            _formatarNumero(entry.value.valorCentavos),
          ]),
      [],
      ['Orçamentos do período'],
      ['Data do evento', 'Cliente', 'Status', 'Convidados', 'Total (R\$)'],
      ...controller.orcamentosFiltrados.map((registro) => [
            _data.format(registro.orcamento.dataEvento),
            _protegerFormula(registro.cliente.nome),
            _statusLegivel(registro.orcamento.status),
            '${registro.orcamento.convidados}',
            _formatarNumero(registro.totalCentavos),
          ]),
      [],
      ['Observação', 'Valores são totais dos orçamentos, não pagamentos recebidos.'],
    ];

    final conteudo = linhas
        .map((linha) => linha.map(_csvCelula).join(';'))
        .join('\r\n');
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(conteudo)]);
  }

  static pw.Widget _tituloSecao(String texto) => pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 12,
          color: _marinho,
          fontWeight: pw.FontWeight.bold,
        ),
      );

  static String _formatarMoeda(int centavos) => _moeda.format(centavos / 100);
  static String _formatarNumero(int centavos) => _numero.format(centavos / 100).trim();

  static String _csvCelula(String texto) {
    final precisaAspas = texto.contains(';') ||
        texto.contains('"') ||
        texto.contains('\n') ||
        texto.contains('\r');
    final escapado = texto.replaceAll('"', '""');
    return precisaAspas ? '"$escapado"' : escapado;
  }

  static String _protegerFormula(String texto) {
    final valor = texto.trimLeft();
    if (valor.startsWith('=') ||
        valor.startsWith('+') ||
        valor.startsWith('-') ||
        valor.startsWith('@')) {
      return "'$texto";
    }
    return texto;
  }

  static String _statusLegivel(String status) {
    final normalizado = status.toLowerCase().trim();
    return switch (normalizado) {
      'aprovado' => 'Aprovado',
      'enviado' => 'Enviado',
      'pendente' => 'Pendente',
      'perdido' => 'Perdido',
      'recusado' => 'Recusado',
      _ => status.isEmpty ? '—' : status[0].toUpperCase() + status.substring(1),
    };
  }

  static String _carimbo() {
    final agora = DateTime.now();
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${agora.year}${dois(agora.month)}${dois(agora.day)}_${dois(agora.hour)}${dois(agora.minute)}${dois(agora.second)}';
  }
}
