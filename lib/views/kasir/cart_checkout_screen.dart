import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import 'payment_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _nameController = TextEditingController(text: cart.customerName);
    _notesController = TextEditingController(text: cart.generalNotes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.softSand,
      appBar: AppBar(
        title: Text(
          'KERANJANG PESANAN',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Kosongkan Keranjang',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Kosongkan Keranjang?'),
                    content: const Text('Seluruh item yang dipilih akan dihapus dari pesanan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.berryRed),
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus Semua'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Masih Kosong',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan pilih menu minuman atau makanan di katalog.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke Menu'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Starbucks-Style Order Calling Identification Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.activePillCream,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.campaign_rounded,
                                      size: 20,
                                      color: AppColors.espressoDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SISTEM PANGGILAN ANTREAN',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.espressoDark,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          'Pesanan dipanggil saat siap di Barista Counter',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nama Pelanggan (Untuk Panggilan) *',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                onChanged: (val) => cart.setCustomerName(val.trim()),
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.roastedCoffee),
                                  hintText: 'Contoh: Kak Sarah, Dimas, Budi',
                                  filled: true,
                                  fillColor: const Color(0xFFFAFAFA),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.roastedCoffee, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section Title
                        Text(
                          'DAFTAR ITEM PESANAN (${cart.items.length}):',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Items List
                        ...cart.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        CurrencyFormatter.format(item.unitPrice),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.activePillCream.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '📝 ${item.notes}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppColors.espressoDark,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                      icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textMuted),
                                      onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, size: 22, color: AppColors.roastedCoffee),
                                      onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // General Notes Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan Tambahan Transaksi (Opsional):',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _notesController,
                                onChanged: (val) => cart.setGeneralNotes(val),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Tolong makanan & minuman dikeluarkan bersamaan',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Checkout Calculation & Action Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                          Text(CurrencyFormatter.format(cart.subtotalAmount), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PB1 / Pajak Resto (10%):', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                          Text(CurrencyFormatter.format(cart.taxAmount), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL BAYAR:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.espressoDark,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(cart.totalAmount),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.roastedCoffee,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.roastedCoffee,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            // If customer name is empty, auto-assign or warn
                            if (cart.customerName.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Silakan masukkan Nama Pelanggan untuk panggilan antrean!'),
                                  backgroundColor: AppColors.amberOrange,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentScreen()),
                            );
                          },
                          child: Text(
                            'PILIH PEMBAYARAN ➔',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
