import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_menu_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_settings_tab.dart';
import 'tabs/admin_stock_tab.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialIndex;
  const AdminMainScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      AdminDashboardTab(onTabNavigate: _onTabSelected),
      AdminMenuTab(onTabNavigate: _onTabSelected),
      const AdminStockTab(),
      const AdminReportsTab(),
      const AdminSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

class _AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItemData(icon: Icons.pie_chart_rounded, label: 'Dashboard'),
    _NavItemData(icon: Icons.inventory_2_rounded, label: 'Produk'),
    _NavItemData(icon: Icons.fact_check_rounded, label: 'Stok'),
    _NavItemData(icon: Icons.receipt_long_rounded, label: 'Riwayat'),
    _NavItemData(icon: Icons.settings_rounded, label: 'Sistem'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0E6DC), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D38220F),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4A2E21)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          size: isSelected ? 20 : 22,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFA88B77),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF4A2E21)
                              : const Color(0xFFA88B77),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}
