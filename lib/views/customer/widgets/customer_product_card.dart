import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';

class CustomerProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;

  const CustomerProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLimitedStock = product.trackStock && product.stock > 0 && product.stock <= 15;
    final isOutOfStock = product.trackStock && product.stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38220F).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap ?? onAddToCart,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Square Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 86,
                    height: 86,
                    child: _buildImage(product.imageUrl),
                  ),
                ),

                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Row: Title + Status Tag
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(isOutOfStock, isLimitedStock),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Description / Subtitle
                      Text(
                        product.description ?? 'Specialty Menu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9E8E82),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Bottom Row: Price (Single Line, Clean) & Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price text without broken wraps!
                          Text(
                            CurrencyFormatter.formatRupiah(product.price),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          // Plus Button
                          InkWell(
                            onTap: isOutOfStock ? null : onAddToCart,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? const Color(0xFFE5E7EB)
                                    : AppColors.figmaCoffee,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  color: isOutOfStock
                                      ? const Color(0xFF9CA3AF)
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOutOfStock, bool isLimitedStock) {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'HABIS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFDC2626),
          ),
        ),
      );
    }

    if (isLimitedStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.figmaStockBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.figmaStockTeal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${product.stock} LEFT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.figmaStockTeal,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.figmaReadyBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.figmaReadyGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'READY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.figmaReadyGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.figmaSoftCream,
        child: const Icon(Icons.coffee_rounded, color: AppColors.figmaHazelnut, size: 28),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.figmaSoftCream,
          child: const Icon(Icons.coffee_rounded, color: AppColors.figmaHazelnut, size: 28),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.figmaSoftCream,
        child: const Icon(Icons.coffee_rounded, color: AppColors.figmaHazelnut, size: 28),
      ),
    );
  }
}
