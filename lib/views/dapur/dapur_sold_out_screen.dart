import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/menu_provider.dart';

class DapurSoldOutScreen extends StatelessWidget {
  const DapurSoldOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: const Text('STATUS MENU (MODE 86)'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.creamLatte.withOpacity(0.5),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.roastedCoffee),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sentuh saklar jika bahan baku habis. Status otomatis tersinkron ke layar kasir agar menu tidak dapat dijual.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.espressoDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: menu.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = menu.products[index];
                final isAvailable = product.isActive && (!product.trackStock || product.stock > 0);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAvailable ? AppColors.borderSubtle : AppColors.berryRed.withOpacity(0.4),
                      width: isAvailable ? 1 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.creamLatte.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.coffee, color: AppColors.roastedCoffee),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isAvailable ? AppColors.espressoDark : AppColors.textMuted,
                                decoration: isAvailable ? null : TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.format(product.price)} • Stok: ${product.stock}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        activeColor: AppColors.matchaGreen,
                        inactiveThumbColor: AppColors.berryRed,
                        inactiveTrackColor: AppColors.berryRed.withOpacity(0.2),
                        value: product.isActive,
                        onChanged: (val) {
                          menu.toggleSoldOut(product.id, !val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
