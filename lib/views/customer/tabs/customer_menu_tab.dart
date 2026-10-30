import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/customer_product_card.dart';

class CustomerMenuTab extends StatefulWidget {
  final bool autoFocusSearch;

  const CustomerMenuTab({super.key, this.autoFocusSearch = false});

  @override
  State<CustomerMenuTab> createState() => _CustomerMenuTabState();
}

class _CustomerMenuTabState extends State<CustomerMenuTab> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getSearchHint() {
    if (_selectedCategory == 'Semua') {
      return 'Cari kopi, beans, atau snack...';
    }
    return 'Cari di $_selectedCategory...';
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.read<CartProvider>();

    // Dynamic category list from MenuProvider or defaults
    final categories = [
      'Semua',
      ...menu.categories.map((c) => c.name),
    ];

    // Filter products
    var products = menu.products.where((p) => p.isActive).toList();
    if (_selectedCategory != 'Semua') {
      final selectedCat = menu.categories.where((c) => c.name == _selectedCategory).toList();
      if (selectedCat.isNotEmpty) {
        products = products.where((p) => p.categoryId == selectedCat.first.id).toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // 1. Title: Eksplor Menu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Eksplor Menu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 2. Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2EC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEADBCE),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _getSearchHint(),
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0A094),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFB0A094),
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Category Pills (Horizontal Scrollable - fixed layout, no clipping)
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.figmaCoffee : const Color(0xFFF7F2EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.figmaCoffee : const Color(0xFFEADBCE),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF7A5C4A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 4. Products List
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 50,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tidak ada menu ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba kata kunci atau kategori lain.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return CustomerProductCard(
                      product: product,
                      onAddToCart: () {
                        cart.addItem(product: product);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ditambahkan ke keranjang.'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.figmaCoffee,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
