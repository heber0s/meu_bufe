import 'package:intl/intl.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

/// Todo valor financeiro do app é guardado em centavos (int).
String formatarMoeda(int centavos) => _moeda.format(centavos / 100);

String diaDoEvento(DateTime d) => DateFormat('dd', 'pt_BR').format(d);
String mesDoEvento(DateTime d) =>
    DateFormat('MMM', 'pt_BR').format(d).replaceAll('.', '').toUpperCase();
String dataCompleta(DateTime d) =>
    DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(d);