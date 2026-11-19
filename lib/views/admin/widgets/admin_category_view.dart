import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../providers/menu_provider.dart';
import 'admin_header.dart';

class AdminCategoryView extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<CategoryModel> onEditCategory;
  final ValueChanged<CategoryModel> onDeleteCategory;

  const AdminCategoryView({
    super.key,
    required this.searchQuery,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  String _resolveCategoryThumbnail(MenuProvider menu, CategoryModel cat) {
    // Use first product photo belonging to this category if available
    for (final p in menu.products) {
      if (p.categoryId == cat.id &&
          p.imageUrl != null &&
          p.imageUrl!.trim().isNotEmpty) {
        return p.imageUrl!.trim();
      }
    }

    // Curated fallback by category name/icon
    final lower = '${cat.name.toLowerCase()} ${cat.icon.toLowerCase()}';
    if (lower.contains('non-coffee') || lower.contains('matcha') || lower.contains('drink')) {
      return 'assets/images/products/matcha_latte.png';
    }
    if (lower.contains('pastry') || lower.contains('food') || lower.contains('cake') || lower.contains('snack')) {
      return 'assets/images/products/butter_croissant.png';
    }
    if (lower.contains('manual') || lower.contains('latte')) {
      return 'assets/images/products/cafe_latte.png';
    }
    if (lower.contains('beans') || lower.contains('grain')) {
      return 'assets/images/products/iced_americano.png';
    }
    return 'assets/images/products/coffi_aren.png';
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final query = searchQuery.trim().toLowerCase();

    final filtered = menu.categories.where((c) {
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 96),
        children: [
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFE5DB)),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.figmaHazelnut,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kategori tidak ditemukan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.figmaCoffee,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba kata kunci lain atau tambah kategori baru di kanan bawah.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9C7F6C),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = filtered[index];
        final productCount =
            menu.products.where((p) => p.categoryId == category.id).length;
        final previewUrl = _resolveCategoryThumbnail(menu, category);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF3ECE4), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.figmaCoffee.withOpacity(0.045),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onEditCategory(category),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Soft cream framed thumbnail matching Reference Image 4
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFE7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AdminProductImage(
                        imageUrl: previewUrl,
                        size: 46,
                        borderRadius: 12,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.figmaCoffee,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$productCount Produk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFA88D7B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: const Color(0xFFFFF5F5),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onDeleteCategory(category),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFDE2E2)),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFE14949),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
