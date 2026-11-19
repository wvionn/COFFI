import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormatter = NumberFormat.decimalPattern(
    'id_ID',
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatRupiah(num amount) {
    return _formatter.format(amount);
  }

  /// Formats number with Indonesian thousands dots (e.g. 25000 -> "25.000").
  static String formatNumber(num amount) {
    return _numberFormatter.format(amount.round());
  }

  /// Parses formatted currency/number string back to double (e.g. "25.000" -> 25000.0).
  static double parse(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return 0.0;
    return double.tryParse(digitsOnly) ?? 0.0;
  }

  /// Formats prices in thousands format (e.g. 22000 -> "22.0", 6900 -> "6.9")
  static String formatK(num amount) {
    final double val = amount >= 100 ? amount / 1000 : amount.toDouble();
    return val.toStringAsFixed(1);
  }

  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      final double inM = amount / 1000000;
      return 'Rp ${inM.toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      final double inK = amount / 1000;
      return 'Rp ${inK.toStringAsFixed(0)}K';
    }
    return format(amount);
  }
}

/// Automatically inserts Indonesian thousands dot separators while typing (e.g. "25000" -> "25.000").
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Remove leading zeros unless the value is just "0"
    final normalized = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final number = int.tryParse(normalized);
    if (number == null) return oldValue;

    final formatted = CurrencyFormatter.formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
