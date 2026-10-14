import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/table_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/table_provider.dart';

class TableSelectorSheet extends StatefulWidget {
  const TableSelectorSheet({super.key});

  @override
  State<TableSelectorSheet> createState() => _TableSelectorSheetState();
}

class _TableSelectorSheetState extends State<TableSelectorSheet> {
  TableModel? _tempSelectedTable;

  @override
  void initState() {
    super.initState();
    _tempSelectedTable = context.read<CartProvider>().selectedTable;
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = context.watch<TableProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.oatMilkFoam,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_restaurant_rounded, color: AppColors.roastedCoffee),
                    const SizedBox(width: 8),
                    Text(
                      'PILIH MEJA CAFE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Status Legends
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegend(AppColors.matchaGreen, 'Kosong'),
                  _buildLegend(AppColors.berryRed, 'Terisi'),
                  _buildLegend(AppColors.coldBrewBlue, 'Terpilih'),
                ],
              ),
            ),
          ),

          // Area Filter Chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tableProvider.availableAreas.length,
              itemBuilder: (context, index) {
                final area = tableProvider.availableAreas[index];
                final isSelected = tableProvider.selectedAreaFilter == area;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(area),
                    selected: isSelected,
                    selectedColor: AppColors.creamLatte,
                    checkmarkColor: AppColors.roastedCoffee,
                    onSelected: (_) => tableProvider.setAreaFilter(area),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Table Grid
          Expanded(
            child: tableProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: tableProvider.filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = tableProvider.filteredTables[index];
                      final isCurrentChoice = _tempSelectedTable?.id == table.id;

                      Color borderColor;
                      Color bgColor;
                      Color textColor;
                      Color statusBadgeColor;
                      String statusText;

                      if (isCurrentChoice) {
                        borderColor = AppColors.coldBrewBlue;
                        bgColor = AppColors.coldBrewBlue.withOpacity(0.08);
                        textColor = AppColors.coldBrewBlue;
                        statusBadgeColor = AppColors.coldBrewBlue;
                        statusText = 'Terpilih';
                      } else if (table.isOccupied) {
                        borderColor = AppColors.berryRed.withOpacity(0.3);
                        bgColor = AppColors.berryRed.withOpacity(0.05);
                        textColor = AppColors.berryRed;
                        statusBadgeColor = AppColors.berryRed;
                        statusText = 'Terisi';
                      } else {
                        borderColor = AppColors.matchaGreen.withOpacity(0.4);
                        bgColor = Colors.white;
                        textColor = AppColors.textPrimary;
                        statusBadgeColor = AppColors.matchaGreen;
                        statusText = 'Kosong';
                      }

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (table.isOccupied && !isCurrentChoice) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${table.tableNumber} sedang terisi pelanggan!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _tempSelectedTable = table;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: isCurrentChoice ? 2.2 : 1.2),
                            boxShadow: [
                              if (isCurrentChoice)
                                BoxShadow(
                                  color: AppColors.coldBrewBlue.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                table.tableNumber,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusBadgeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusBadgeColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${table.capacity} Kursi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Confirmation Action Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tempSelectedTable != null ? AppColors.roastedCoffee : Colors.grey.shade400,
                ),
                onPressed: _tempSelectedTable == null
                    ? null
                    : () {
                        cartProvider.setOrderType('dine_in');
                        cartProvider.setSelectedTable(_tempSelectedTable);
                        Navigator.pop(context);
                      },
                child: Text(
                  _tempSelectedTable != null
                      ? 'KONFIRMASI ${_tempSelectedTable!.tableNumber.toUpperCase()}'
                      : 'PILIH MEJA DAHULU',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
