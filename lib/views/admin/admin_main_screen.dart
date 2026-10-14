import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> tabs = [
      AdminDashboardTab(onTabNavigate: _onTabSelected),
      const AdminMenuTab(),
      const AdminStockTab(),
      const AdminReportsTab(),
      const AdminSettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppColors.creamLatte,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.roastedCoffee),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            selectedIcon: Icon(Icons.coffee, color: AppColors.roastedCoffee),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.roastedCoffee),
            label: 'Stok',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppColors.roastedCoffee),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.roastedCoffee),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
