import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/table_provider.dart';

class CustomerCartSheet extends StatefulWidget {
  final VoidCallback onOrderPlaced;

  const CustomerCartSheet({super.key, required this.onOrderPlaced});

  @override
  State<CustomerCartSheet> createState() => _CustomerCartSheetState();
}

class _CustomerCartSheetState extends State<CustomerCartSheet> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    _nameController.text = cart.customerName.isNotEmpty
        ? cart.customerName
        : (auth.currentProfile?.fullName ?? '');
    _notesController.text = cart.generalNotes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final cart = context.read<CartProvider>();
    final tableProv = context.read<TableProvider>();
    final auth = context.read<AuthProvider>();

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

    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.createCustomerOrder(
      cart: cart,
      customerProfile: auth.currentProfile,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      if (cart.isDineIn && cart.selectedTable != null) {
        final orderId = orderProv.activeOrders.isNotEmpty ? orderProv.activeOrders.first.id : 'order_';
        await tableProv.occupyTable(cart.selectedTable!.id, orderId);
      }
      cart.clearCart();
      Navigator.pop(context);
      widget.onOrderPlaced();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProv.errorMessage ?? 'Gagal membuat pesanan. Coba lagi.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final tableProv = context.watch<TableProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.figmaSoftCream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.figmaCoffee,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keranjang Pesanan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${cart.totalItemsCount} item dipilih',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (cart.items.isNotEmpty)
                  TextButton(
                    onPressed: cart.clearCart,
                    child: Text(
                      'Hapus Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.berryRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEADBCE)),

          // Scrollable Items List
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 52,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keranjang masih kosong',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih menu favorit Anda sekarang.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    children: [
                      // Order Mode Switcher
                      Row(
                        children: [
                          Expanded(
                            child: _buildModeToggle(
                              title: 'Dine In (Santap Kafe)',
                              isSelected: cart.isDineIn,
                              onTap: () => cart.setOrderType('dine_in'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildModeToggle(
                              title: 'Take Away (Bungkus)',
                              isSelected: cart.isTakeaway,
                              onTap: () => cart.setOrderType('takeaway'),
                            ),
                          ),
                        ],
                      ),

                      if (cart.isDineIn) ...[
                        const SizedBox(height: 14),
                        _buildTableSelector(context, cart, tableProv),
                      ],

                      const SizedBox(height: 18),

                      Text(
                        'DAFTAR ITEM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.figmaHazelnut,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...cart.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDFAF7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEADBCE)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      CurrencyFormatter.formatRupiah(item.unitPrice),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.figmaHazelnut,
                                      ),
                                    ),
                                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Catatan: ${item.notes}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                    color: AppColors.figmaCoffee,
                                    iconSize: 22,
                                    onPressed: () => cart.decrementItem(item.id),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    color: AppColors.figmaCoffee,
                                    iconSize: 22,
                                    onPressed: () => cart.incrementItem(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      // Customer notes input
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan instruksi / catatan pesanan...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Sticky Bottom Checkout Summary
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtotal & Tax details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cart.totalItemsCount} item)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(cart.subtotalAmount),
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PB1 (10%)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(cart.taxAmount),
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFEADBCE)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(cart.totalAmount),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.figmaCoffee,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.figmaCoffee,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitOrder,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Kirim Pesanan Sekarang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaCoffee : const Color(0xFFF5EFE9),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.figmaCoffee,
          ),
        ),
      ),
    );
  }

  Widget _buildTableSelector(
    BuildContext context,
    CartProvider cart,
    TableProvider tableProv,
  ) {
    final availableTables = tableProv.tables.where((t) => t.isAvailable).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFAF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.table_restaurant_rounded, size: 20, color: AppColors.figmaCoffee),
              const SizedBox(width: 8),
              Text(
                cart.selectedTable != null
                    ? '${cart.selectedTable!.tableNumber} (${cart.selectedTable!.area})'
                    : 'Pilih Nomor Meja:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          DropdownButton<String>(
            value: cart.selectedTable?.id,
            hint: Text(
              'Pilih',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
            ),
            underline: const SizedBox(),
            items: availableTables.map((t) {
              return DropdownMenuItem(
                value: t.id,
                child: Text(
                  '${t.tableNumber} (${t.capacity} org)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                final selected = tableProv.tables.firstWhere((t) => t.id == id);
                cart.setSelectedTable(selected);
              }
            },
          ),
        ],
      ),
    );
  }
}
