import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';

class CustomerProductCustomizationSheet extends StatefulWidget {
  final ProductModel product;

  const CustomerProductCustomizationSheet({
    super.key,
    required this.product,
  });

  static Future<void> show(BuildContext context, ProductModel product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerProductCustomizationSheet(product: product),
    );
  }

  @override
  State<CustomerProductCustomizationSheet> createState() =>
      _CustomerProductCustomizationSheetState();
}

class _CustomerProductCustomizationSheetState
    extends State<CustomerProductCustomizationSheet> {
  // Temperature: 'Ice' or 'Hot'
  String _selectedTemperature = 'Ice';

  // Sugar Level: 'NORMAL', 'LESS', 'NO SUGAR'
  String _selectedSugar = 'NORMAL';

  // Add-ons
  bool _extraShot = false;
  bool _oatMilk = false;

  final double _extraShotPrice = 5000.0;
  final double _oatMilkPrice = 10000.0;

  double get _calculatedUnitPrice {
    double total = widget.product.price;
    if (_extraShot) total += _extraShotPrice;
    if (_oatMilk) total += _oatMilkPrice;
    return total;
  }

  String get _formattedNotes {
    final List<String> notes = [];
    notes.add(_selectedTemperature);

    if (_selectedSugar == 'NORMAL') {
      notes.add('Normal Sugar');
    } else if (_selectedSugar == 'LESS') {
      notes.add('Less Sugar');
    } else {
      notes.add('No Sugar');
    }

    if (_extraShot) notes.add('Extra Shot');
    if (_oatMilk) notes.add('Oat Milk');

    return notes.join(', ');
  }

  void _handleAddToCart() {
    final cart = context.read<CartProvider>();
    cart.addItem(
      product: widget.product,
      quantity: 1,
      notes: _formattedNotes,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ditambahkan ke keranjang.'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.figmaCoffee,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxSheetHeight = size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Image with Close Button
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 230,
                          child: _buildHeaderImage(widget.product.imageUrl),
                        ),
                      ),

                      // Circular Close 'X' Button on top left
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Material(
                          color: Colors.black.withOpacity(0.42),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.pop(context),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Product Info Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.figmaCoffee,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              CurrencyFormatter.formatK(widget.product.price),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: AppColors.figmaCoffee,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Description
                        Text(
                          widget.product.description ??
                              'Espresso khas COFFI dengan paduan susu segar dan gula aren asli yang creamy.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9E8E82),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 1. TEMPERATURE SECTION
                        _buildSectionHeader('TEMPERATURE'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPillOption(
                                label: 'Ice',
                                icon: Icons.ac_unit_rounded,
                                isSelected: _selectedTemperature == 'Ice',
                                onTap: () =>
                                    setState(() => _selectedTemperature = 'Ice'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPillOption(
                                label: 'Hot',
                                icon: Icons.local_fire_department_rounded,
                                isSelected: _selectedTemperature == 'Hot',
                                onTap: () =>
                                    setState(() => _selectedTemperature = 'Hot'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // 2. SUGAR LEVEL SECTION
                        _buildSectionHeader('SUGAR LEVEL'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextPill(
                                label: 'NORMAL',
                                isSelected: _selectedSugar == 'NORMAL',
                                onTap: () =>
                                    setState(() => _selectedSugar = 'NORMAL'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextPill(
                                label: 'LESS',
                                isSelected: _selectedSugar == 'LESS',
                                onTap: () =>
                                    setState(() => _selectedSugar = 'LESS'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextPill(
                                label: 'NO SUGAR',
                                isSelected: _selectedSugar == 'NO SUGAR',
                                onTap: () =>
                                    setState(() => _selectedSugar = 'NO SUGAR'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // 3. ADD-ONS SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader('ADD-ONS'),
                            Text(
                              'Opsional',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA18A7B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Add-on 1: Extra Shot
                        _buildAddOnCard(
                          title: 'Extra Shot',
                          price: '+5.0',
                          isChecked: _extraShot,
                          onToggle: () =>
                              setState(() => _extraShot = !_extraShot),
                        ),

                        const SizedBox(height: 10),

                        // Add-on 2: Oat Milk
                        _buildAddOnCard(
                          title: 'Oat Milk',
                          price: '+10.0',
                          isChecked: _oatMilk,
                          onToggle: () => setState(() => _oatMilk = !_oatMilk),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar
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
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  onPressed: _handleAddToCart,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TAMBAH KE KERANJANG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatK(_calculatedUnitPrice),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.figmaCoffee,
      ),
    );
  }

  Widget _buildPillOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFF7EFE9) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.figmaCoffee : const Color(0xFFEADBCE),
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.figmaCoffee
                    : const Color(0xFF8C7769),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.figmaCoffee
                      : const Color(0xFF8C7769),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? const Color(0xFFF7EFE9) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.figmaCoffee : const Color(0xFFEADBCE),
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0.4,
              color: isSelected
                  ? AppColors.figmaCoffee
                  : const Color(0xFF8C7769),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnCard({
    required String title,
    required String price,
    required bool isChecked,
    required VoidCallback onToggle,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChecked
                  ? const Color(0xFFCDB29E)
                  : const Color(0xFFEADBCE),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Custom Checkbox
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isChecked
                        ? AppColors.figmaCoffee
                        : const Color(0xFFBFAF9E),
                    width: 1.5,
                  ),
                  color: isChecked ? AppColors.figmaCoffee : Colors.transparent,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.figmaCoffee,
                  ),
                ),
              ),
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA18A7B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(String? url) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        'assets/images/products/coffi_aren.png',
        fit: BoxFit.cover,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/products/coffi_aren.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/products/coffi_aren.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

