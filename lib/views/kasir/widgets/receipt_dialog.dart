import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';

class ReceiptDialog extends StatelessWidget {
  final OrderModel order;
  final String paymentMethod;
  final double amountPaid;
  final double changeAmount;
  final VoidCallback onNewTransaction;

  const ReceiptDialog({
    super.key,
    required this.order,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    required this.onNewTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thermal Paper Receipt Card
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success Check Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.matchaGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.matchaGreen,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'TRANSAKSI BERHASIL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.matchaGreen,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Pesanan telah diteruskan ke layar dapur',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildDashedLine(),
                    const SizedBox(height: 12),

                    // Cafe Header
                    Center(
                      child: Text(
                        'CAFEKU COFFEE & RESTO',
                        style: GoogleFonts.courierPrime(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Jl. Kampus Merdeka No. 42',
                        style: GoogleFonts.courierPrime(fontSize: 11),
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildDashedLine(),
                    const SizedBox(height: 10),

                    // Metadata
                    _buildReceiptRow('No. Struk', order.invoiceNumber),
                    _buildReceiptRow('Waktu', dateFormat.format(order.createdAt)),
                    _buildReceiptRow('Kasir', order.cashierName ?? 'Siti Rahma'),
                    _buildReceiptRow(
                      'Atas Nama',
                      order.customerName?.isNotEmpty == true ? order.customerName! : 'Pelanggan',
                      isBold: true,
                    ),

                    const SizedBox(height: 10),
                    _buildDashedLine(),
                    const SizedBox(height: 10),

                    // Order Items
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: GoogleFonts.courierPrime(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.subtotal),
                                  style: GoogleFonts.courierPrime(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 2),
                                child: Text(
                                  '* ${item.notes}',
                                  style: GoogleFonts.courierPrime(
                                    fontSize: 10,
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Summary & Payment
                    _buildReceiptRow('Subtotal', CurrencyFormatter.format(order.subtotalAmount)),
                    _buildReceiptRow('PB1 / Pajak Resto (10%)', CurrencyFormatter.format(order.taxAmount)),
                    const SizedBox(height: 4),
                    _buildReceiptRow('TOTAL BAYAR', CurrencyFormatter.format(order.totalAmount), isBold: true, isLarge: true),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Metode Bayar', paymentMethod.toUpperCase()),
                    _buildReceiptRow('Uang Diterima', CurrencyFormatter.format(amountPaid)),
                    _buildReceiptRow('Kembalian', CurrencyFormatter.format(changeAmount), isBold: true),

                    const SizedBox(height: 12),
                    _buildDashedLine(),
                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'Terima Kasih Atas Kunjungan Anda!',
                        style: GoogleFonts.courierPrime(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Wifi: Cafeku_Guest / Pass: kopienak',
                        style: GoogleFonts.courierPrime(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🖨️ Mencetak struk ke Printer Bluetooth Thermal 58mm...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('💬 Menyiapkan struk digital untuk dikirim ke WhatsApp...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Kirim WA'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onNewTransaction();
                    },
                    child: const Text('➕ Transaksi Baru'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.courierPrime(
              fontSize: isLarge ? 13 : 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.courierPrime(
              fontSize: isLarge ? 13 : 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black45),
              ),
            );
          }),
        );
      },
    );
  }
}
