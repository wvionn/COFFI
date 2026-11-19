import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/addon_model.dart';
import '../../../providers/menu_provider.dart';
import 'admin_header.dart';

class AdminAddonView extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<AddonModel> onEditAddon;
  final ValueChanged<AddonModel> onDeleteAddon;

  const AdminAddonView({
    super.key,
    required this.searchQuery,
    required this.onEditAddon,
    required this.onDeleteAddon,
  });

  @override
  State<AdminAddonView> createState() => _AdminAddonViewState();
}

class _AdminAddonViewState extends State<AdminAddonView> {
  String? _selectedGroup; // null = semua grup
  bool _onlyActive = false;

  void _showGroupPicker(BuildContext context, List<String> groups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.figmaSubtleBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter Kategori Add-on',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.figmaCoffee,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildGroupChip(
                    label: 'Semua',
                    isSelected: _selectedGroup == null,
                    onTap: () {
                      setState(() => _selectedGroup = null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...groups.map(
                    (g) => _buildGroupChip(
                      label: g,
                      isSelected: _selectedGroup == g,
                      onTap: () {
                        setState(() => _selectedGroup = g);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.figmaCoffee : const Color(0xFFFAF5F0),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? AppColors.figmaCoffee : const Color(0xFFE8DDD3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.figmaCoffee,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final query = widget.searchQuery.trim().toLowerCase();
    final groups = menu.addonGroups.toList()..sort();

    final filtered = menu.addons.where((a) {
      if (_onlyActive && !a.isActive) return false;
      if (_selectedGroup != null && a.group != _selectedGroup) return false;
      if (query.isNotEmpty) {
        return a.name.toLowerCase().contains(query) ||
            a.group.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        // 2 Summary KPI Cards matching Reference Image 3
        Row(
          children: [
            Expanded(
              child: Material(
                color: const Color(0xFFF5EDE5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _onlyActive = !_onlyActive),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _onlyActive
                            ? AppColors.figmaCoffee
                            : const Color(0xFFE9DFD4),
                        width: _onlyActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AKTIF',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: const Color(0xFF9C7F6C),
                              ),
                            ),
                            if (_onlyActive)
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.figmaLimitedGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${menu.activeAddons.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaCoffee,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showGroupPicker(context, groups),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedGroup != null
                            ? AppColors.figmaCoffee
                            : const Color(0xFFF0E6DC),
                        width: _selectedGroup != null ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.figmaCoffee.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'KATEGORI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: const Color(0xFF9C7F6C),
                              ),
                            ),
                            const Icon(
                              Icons.filter_list_rounded,
                              size: 14,
                              color: Color(0xFF9C7F6C),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${menu.addonGroups.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaCoffee,
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

        const SizedBox(height: 20),

        // Section Label + Active Filter Clear Pill
        Row(
          children: [
            Expanded(
              child: Text(
                'DAFTAR ADD-ON',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF9C7F6C),
                ),
              ),
            ),
            if (_selectedGroup != null || _onlyActive)
              GestureDetector(
                onTap: () => setState(() {
                  _selectedGroup = null;
                  _onlyActive = false;
                }),
                child: Text(
                  'Reset Filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.figmaCoffee,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 42),
            child: Column(
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
                    Icons.tune_rounded,
                    color: AppColors.figmaHazelnut,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Varian atau add-on tidak ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaCoffee,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coba kata kunci lain atau tekan tombol + di kanan bawah.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
              ],
            ),
          )
        else
          ...filtered.map(
            (addon) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAddonCard(addon),
            ),
          ),
      ],
    );
  }

  Widget _buildAddonCard(AddonModel addon) {
    final priceLabel = addon.price > 0
        ? '+${CurrencyFormatter.format(addon.price)}'
        : 'Gratis';

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
          onTap: () => widget.onEditAddon(addon),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Opacity(
                  opacity: addon.isActive ? 1.0 : 0.45,
                  child: AdminProductImage(
                    imageUrl: addon.imageUrl,
                    size: 56,
                    borderRadius: 14,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            addon.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: addon.isActive
                                  ? AppColors.figmaCoffee
                                  : AppColors.textMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFEFE5DB),
                              ),
                            ),
                            child: Text(
                              addon.group.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: const Color(0xFF9C7F6C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            priceLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: addon.isActive
                                  ? const Color(0xFF6B4736)
                                  : AppColors.textMuted,
                            ),
                          ),
                          if (!addon.isActive) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• Nonaktif',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
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
                    onTap: () => widget.onDeleteAddon(addon),
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
  }
}
