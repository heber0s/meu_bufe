import 'package:flutter/services.dart';
import 'formatters.dart';

/// Digita-se só os números e o campo vai formatando: 1 → R$ 0,01 → 12 → R$ 0,12 ...
class MoedaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return const TextEditingValue(text: '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final texto = formatarMoeda(int.parse(digitos));
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Converte "R$ 1.234,56" em 123456 (centavos).
int centavosDoTexto(String texto) {
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  return digitos.isEmpty ? 0 : int.parse(digitos);
}