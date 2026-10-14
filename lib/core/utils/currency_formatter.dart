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
