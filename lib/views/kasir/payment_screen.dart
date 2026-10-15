import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'widgets/receipt_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cash'; // 'cash', 'qris', 'transfer'
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _refNumberController = TextEditingController();
  double _amountPaid = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _amountPaid = cart.totalAmount;
    _cashController.text = _amountPaid.toInt().toString();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _refNumberController.dispose();
    super.dispose();
  }

  void _setQuickNominal(double amount) {
    setState(() {
      _amountPaid = amount;
      _cashController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final totalBill = cart.totalAmount;
    final changeAmount = (_amountPaid - totalBill).clamp(0.0, 999999999.0);
    final isCashSufficient = _selectedMethod != 'cash' || _amountPaid >= totalBill;

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: const Text('PEMBAYARAN KASIR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Amount Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppColors.coffeeGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espressoDark.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'TOTAL TAGIHAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.creamLatte,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(totalBill),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded, color: AppColors.creamLatte, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Atas Nama: ${cart.customerName.isNotEmpty ? cart.customerName : "Pelanggan"}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods Segment
            Text(
              'PILIH METODE PEMBAYARAN:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildMethodButton(
                  id: 'cash',
                  icon: Icons.payments_rounded,
                  label: 'Tunai\n(Cash)',
                ),
                const SizedBox(width: 10),
                _buildMethodButton(
                  id: 'qris',
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'QRIS\nInstan',
                ),
                const SizedBox(width: 10),
                _buildMethodButton(
                  id: 'transfer',
                  icon: Icons.account_balance_rounded,
                  label: 'Transfer\nBank',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Method Specific Content
            if (_selectedMethod == 'cash') ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uang Diterima dari Pelanggan:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _amountPaid = double.tryParse(val) ?? 0.0;
                        });
                      },
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Nominals
                    Text(
                      'Pilihan Cepat Nominal:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Uang Pas'),
                          onPressed: () => _setQuickNominal(totalBill),
                        ),
                        if (totalBill < 50000)
                          ActionChip(
                            label: const Text('Rp 50.000'),
                            onPressed: () => _setQuickNominal(50000),
                          ),
                        if (totalBill < 100000)
                          ActionChip(
                            label: const Text('Rp 100.000'),
                            onPressed: () => _setQuickNominal(100000),
                          ),
                        if (totalBill < 200000)
                          ActionChip(
                            label: const Text('Rp 200.000'),
                            onPressed: () => _setQuickNominal(200000),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Kembalian
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Uang Kembalian:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(changeAmount),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _amountPaid >= totalBill ? AppColors.matchaGreen : AppColors.berryRed,
                          ),
                        ),
                      ],
                    ),
                    if (_amountPaid < totalBill) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⚠️ Uang tunai kurang sebesar ${CurrencyFormatter.format(totalBill - _amountPaid)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.berryRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (_selectedMethod == 'qris') ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Text(
                      'SCAN QRIS DINAMIS COFFI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nominal tagihan otomatis tertera: ${CurrencyFormatter.format(totalBill)}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    // Mock QRIS Box
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 160, color: AppColors.espressoDark),
                          Container(
                            padding: const EdgeInsets.all(4),
                            color: Colors.white,
                            child: const Icon(Icons.coffee_rounded, size: 24, color: AppColors.roastedCoffee),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.matchaGreen),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mendukung BCA, GoPay, OVO, Dana, ShopeePay',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekening Cafe Tujuan:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.creamLatte.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BCA: 8720-9988-1234', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                          Text('A/N: PT COFFI Digital Kuliner', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nomor Referensi Transaksi (Opsional):',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _refNumberController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. TRF-98234812 atau 4 digit terakhir',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCashSufficient ? AppColors.roastedCoffee : Colors.grey,
                ),
                onPressed: (!isCashSufficient || _isProcessing)
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);

                        final cashier = auth.currentProfile;
                        final order = await orderProvider.checkout(
                          orderType: 'counter',
                          tableId: null,
                          tableNumber: null,
                          customerName: cart.customerName.isNotEmpty ? cart.customerName : 'Pelanggan',
                          cashierId: cashier?.id,
                          cashierName: cashier?.fullName ?? 'Kasir',
                          items: cart.items,
                          paymentMethod: _selectedMethod,
                          amountPaid: _selectedMethod == 'cash' ? _amountPaid : totalBill,
                          changeAmount: _selectedMethod == 'cash' ? changeAmount : 0.0,
                          generalNotes: cart.generalNotes,
                        );

                        if (!mounted || !context.mounted) return;

                        setState(() => _isProcessing = false);

                        if (order != null) {
                          // Show receipt dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => ReceiptDialog(
                              order: order,
                              paymentMethod: _selectedMethod,
                              amountPaid: _selectedMethod == 'cash' ? _amountPaid : totalBill,
                              changeAmount: _selectedMethod == 'cash' ? changeAmount : 0.0,
                              onNewTransaction: () {
                                cart.resetAll();
                                Navigator.popUntil(context, (route) => route.isFirst);
                              },
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menyimpan pesanan! Coba lagi.'),
                              backgroundColor: AppColors.berryRed,
                            ),
                          );
                        }
                      },
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'SELESAIKAN & KIRIM KE DAPUR ➔',
                        style: TextStyle(letterSpacing: 0.5),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedMethod == id;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedMethod = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.roastedCoffee : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.roastedCoffee : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.roastedCoffee.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.espressoDark,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
