import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../providers/menu_provider.dart';

class AdminStockTab extends StatefulWidget {
  const AdminStockTab({super.key});

  @override
  State<AdminStockTab> createState() => _AdminStockTabState();
}

class _AdminStockTabState extends State<AdminStockTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRestockModal(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final qtyController = TextEditingController(text: '10');
    final costController = TextEditingController(text: (product.costPrice * 10).toInt().toString());
    final notesController = TextEditingController(text: 'Restock supplier');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock: ${product.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah Masuk (Porsi/Pack):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(controller: qtyController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Text('Total Biaya Beli Modal:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ')),
            const SizedBox(height: 12),
            Text('Catatan Restock:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(controller: notesController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              final cost = double.tryParse(costController.text) ?? 0.0;
              if (qty > 0) {
                menu.restockProduct(
                  productId: product.id,
                  quantity: qty,
                  buyCost: cost,
                  notes: notesController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Berhasil menambah stok +$qty untuk ${product.name}!'), backgroundColor: AppColors.matchaGreen),
                );
              }
            },
            child: const Text('Simpan Stok'),
          ),
        ],
      ),
    );
  }

  void _showOpnameModal(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final actualController = TextEditingController(text: product.stock.toString());
    final reasonController = TextEditingController(text: 'Koreksi fisik harian');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Opname: ${product.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stok Sistem Saat Ini: ${product.stock}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Stok Fisik Aktual:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(controller: actualController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Text('Alasan Penyesuaian (Opname):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(controller: reasonController, decoration: const InputDecoration(hintText: 'e.g. Tumpah, rusak, selisih hitung')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warmCaramel),
            onPressed: () {
              final actual = int.tryParse(actualController.text) ?? product.stock;
              menu.stockOpname(
                productId: product.id,
                actualPhysicalStock: actual,
                reason: reasonController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stok fisik ${product.name} disesuaikan menjadi $actual!'), backgroundColor: AppColors.warmCaramel),
              );
            },
            child: const Text('Koreksi Stok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: const Text('MANAJEMEN STOK & INVENTORI'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.creamLatte,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'DAFTAR STOK'),
            Tab(text: 'RIWAYAT MUTASI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Daftar Stok
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: menu.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = menu.products[index];
              final isLow = product.isLowStock || product.isOutOfStock;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLow ? AppColors.berryRed.withOpacity(0.4) : AppColors.borderSubtle,
                    width: isLow ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.espressoDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isLow ? AppColors.berryRed.withOpacity(0.12) : AppColors.matchaGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isLow ? (product.stock == 0 ? '🔴 HABIS' : '⚠️ MENIPIS') : '🟢 AMAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isLow ? AppColors.berryRed : AppColors.matchaGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Stok Tersedia: ${product.stock} porsi (Min. Batas: ${product.minStock})',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.roastedCoffee,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => _showRestockModal(context, product),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Restock', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => _showOpnameModal(context, product),
                            icon: const Icon(Icons.tune, size: 16),
                            label: const Text('Opname', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Riwayat Mutasi
          menu.stockMovements.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada log mutasi stok tercatat',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: menu.stockMovements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final mov = menu.stockMovements[index];
                    final isIn = mov.isIn;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isIn ? AppColors.matchaGreen.withOpacity(0.12) : AppColors.amberOrange.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIn ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIn ? AppColors.matchaGreen : AppColors.amberOrange,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mov.productName,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${mov.notes ?? "Mutasi"} • ${dateFormat.format(mov.createdAt)}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIn ? "+" : "-"}${mov.quantity}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isIn ? AppColors.matchaGreen : AppColors.amberOrange,
                                ),
                              ),
                              Text(
                                '${mov.stockBefore} ➔ ${mov.stockAfter}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
