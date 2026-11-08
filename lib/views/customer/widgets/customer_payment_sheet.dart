import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/table_provider.dart';

class CustomerPaymentSheet extends StatefulWidget {
  final VoidCallback onOrderSuccess;

  const CustomerPaymentSheet({
    super.key,
    required this.onOrderSuccess,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onOrderSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerPaymentSheet(onOrderSuccess: onOrderSuccess),
    );
  }

  @override
  State<CustomerPaymentSheet> createState() => _CustomerPaymentSheetState();
}

class _CustomerPaymentSheetState extends State<CustomerPaymentSheet> {
  String _selectedMethod = 'qris'; // 'qris', 'cash', 'transfer'
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    _nameController = TextEditingController(
      text: cart.customerName.isNotEmpty
          ? cart.customerName
          : (auth.currentProfile?.fullName ?? ''),
    );
    _notesController = TextEditingController(text: cart.generalNotes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPayment() async {
    final cart = context.read<CartProvider>();
    final tableProv = context.read<TableProvider>();
    final auth = context.read<AuthProvider>();
    final orderProv = context.read<OrderProvider>();

    if (cart.items.isEmpty) return;

    if (cart.isDineIn && cart.selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih nomor meja untuk pesanan Dine In.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    cart.setCustomerName(_nameController.text.trim());
    cart.setGeneralNotes(_notesController.text.trim());

    final order = await orderProv.checkout(
      orderType: cart.orderType,
      tableId: cart.selectedTable?.id,
      tableNumber: cart.selectedTable?.tableNumber,
      customerId: auth.currentProfile?.id,
      customerName: cart.customerName.isNotEmpty
          ? cart.customerName
          : (auth.currentProfile?.fullName ?? 'Pelanggan Tamu'),
      customerPhone: cart.customerPhone,
      deliveryAddress: cart.deliveryAddress,
      cashierId: null,
      cashierName: 'Self-Order (Pelanggan)',
      items: cart.items,
      paymentMethod: _selectedMethod,
      amountPaid: cart.totalAmount,
      changeAmount: 0,
      generalNotes: cart.generalNotes,
      initialStatus: 'pending',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (order != null) {
      if (cart.isDineIn && cart.selectedTable != null) {
        await tableProv.occupyTable(cart.selectedTable!.id, order.id);
      }
      cart.clearCart();
      Navigator.pop(context); // Close payment sheet
      widget.onOrderSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProv.errorMessage ?? 'Gagal membuat pesanan. Silakan coba lagi.',
          ),
          backgroundColor: AppColors.berryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final size = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Metode Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.figmaCoffee,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: ${CurrencyFormatter.formatRupiah(cart.totalAmount)} (${CurrencyFormatter.formatK(cart.totalAmount)})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA18A7B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.figmaCoffee),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEADBCE)),

          // Body Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Options
                  _buildPaymentCard(
                    id: 'qris',
                    title: 'QRIS (Semua E-Wallet & Bank)',
                    subtitle: 'GoPay, OVO, Dana, ShopeePay, BCA, Mandiri',
                    icon: Icons.qr_code_scanner_rounded,
                    badge: 'INSTAN',
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentCard(
                    id: 'cash',
                    title: 'Bayar Tunai di Kasir',
                    subtitle: 'Lakukan pembayaran langsung di counter kasir',
                    icon: Icons.point_of_sale_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentCard(
                    id: 'transfer',
                    title: 'Transfer Bank (VA)',
                    subtitle: 'BCA, Mandiri, BNI, BRI Virtual Account',
                    icon: Icons.account_balance_rounded,
                  ),

                  // If QRIS selected, show preview badge
                  if (_selectedMethod == 'qris') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEADBCE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8DDD3)),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                color: AppColors.figmaCoffee,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QRIS Otomatis Terverifikasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kode QR akan langsung diproses saat pesanan dibuat.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF9E8E82),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Customer Name & Notes Inputs
                  Text(
                    'INFORMASI PEMESAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFFA18A7B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pelanggan',
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF8C7769),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFBF8F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.figmaCoffee,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan Pesanan (Opsional)',
                      hintText: 'Contoh: Jangan terlalu manis, meja pojok...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFFB19A8A),
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF8C7769),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFBF8F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.figmaCoffee,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFEADBCE).withOpacity(0.7),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaCoffee,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleConfirmPayment,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Konfirmasi & Buat Pesanan (${CurrencyFormatter.formatK(cart.totalAmount)})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = _selectedMethod == id;

    return Material(
      color: isSelected ? const Color(0xFFF7EFE9) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = id),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.figmaCoffee : const Color(0xFFEADBCE),
              width: isSelected ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.figmaCoffee : const Color(0xFFF5ECE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.figmaCoffee,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: AppColors.figmaCoffee,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF9E8E82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.figmaCoffee : const Color(0xFFBFAF9E),
                    width: 2,
                  ),
                  color: isSelected ? AppColors.figmaCoffee : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

