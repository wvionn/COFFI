import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatRupiah(num amount) {
    return _formatter.format(amount);
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
