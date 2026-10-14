import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';

class ItemModifierSheet extends StatefulWidget {
  final ProductModel product;

  const ItemModifierSheet({super.key, required this.product});

  @override
  State<ItemModifierSheet> createState() => _ItemModifierSheetState();
}

class _ItemModifierSheetState extends State<ItemModifierSheet> {
  String _temperature = 'Dingin (Iced)';
  String _sugarLevel = 'Normal';
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _buildCombinedNotes() {
    final List<String> parts = [];
    parts.add(_temperature);
    if (_sugarLevel != 'Normal') {
      parts.add(_sugarLevel);
    }
    if (_notesController.text.trim().isNotEmpty) {
      parts.add(_notesController.text.trim());
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final subtotal = widget.product.price * _quantity;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.product.price),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roastedCoffee,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Suhu (Temperature)
              Text(
                'Suhu Minuman:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.ac_unit, size: 16, color: AppColors.coldBrewBlue),
                          SizedBox(width: 6),
                          Text('Dingin (Iced)'),
                        ],
                      ),
                      selected: _temperature == 'Dingin (Iced)',
                      selectedColor: AppColors.creamLatte,
                      onSelected: (val) {
                        if (val) setState(() => _temperature = 'Dingin (Iced)');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department, size: 16, color: AppColors.amberOrange),
                          SizedBox(width: 6),
                          Text('Panas (Hot)'),
                        ],
                      ),
                      selected: _temperature == 'Panas (Hot)',
                      selectedColor: AppColors.creamLatte,
                      onSelected: (val) {
                        if (val) setState(() => _temperature = 'Panas (Hot)');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tingkat Kemanisan (Sugar Level)
              Text(
                'Tingkat Kemanisan (Sugar Level):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Normal', 'Less Sugar', 'No Sugar'].map((level) {
                  final isSelected = _sugarLevel == level;
                  return ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    selectedColor: AppColors.creamLatte,
                    onSelected: (val) {
                      if (val) setState(() => _sugarLevel = level);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Catatan Khusus Dapur
              Text(
                'Catatan Khusus Dapur:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Es sedikit saja, saus sambal pisah, oat milk...',
                ),
              ),

              const SizedBox(height: 16),

              // Quantity Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah (Porsi/Cup):',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.roastedCoffee),
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subtotal & Add Button
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total:',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.format(subtotal),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addItem(
                            product: widget.product,
                            quantity: _quantity,
                            notes: _buildCombinedNotes(),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Simpan ke Pesanan'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
