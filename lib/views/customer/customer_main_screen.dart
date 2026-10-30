import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'tabs/customer_dashboard_tab.dart';
import 'tabs/customer_menu_tab.dart';
import 'tabs/customer_orders_tab.dart';
import 'tabs/customer_profile_tab.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/customer_cart_sheet.dart';

class CustomerMainScreen extends StatefulWidget {
  final String? initialOrderType;
  final int initialTab;
  final bool autoFocusSearch;

  const CustomerMainScreen({
    super.key,
    this.initialOrderType,
    this.initialTab = 0,
    this.autoFocusSearch = false,
  });

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    // Default to requested tab (0: Beranda, 1: Menu, 3: Pesanan, 4: Profil)
    _currentTabIndex = widget.autoFocusSearch ? 1 : widget.initialTab;

    if (widget.initialOrderType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CartProvider>().setOrderType(widget.initialOrderType!);
      });
    }
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerCartSheet(
        onOrderPlaced: () {
          setState(() => _currentTabIndex = 3); // Auto switch to Pesanan tab
        },
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Index 2 is the center floating cart button
      _showCartSheet();
    } else {
      setState(() => _currentTabIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.figmaCreamBg,
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Tab contents
              IndexedStack(
                index: _currentTabIndex > 2 ? _currentTabIndex - 1 : _currentTabIndex,
                children: [
                  // 0: Beranda
                  CustomerDashboardTab(
                    onNavigateToMenu: () => setState(() => _currentTabIndex = 1),
                    onOpenProfile: () => setState(() => _currentTabIndex = 4),
                  ),

                  // 1: Eksplor Menu
                  CustomerMenuTab(
                    autoFocusSearch: widget.autoFocusSearch,
                  ),

                  // 3: Pesanan Saya
                  CustomerOrdersTab(
                    onGoToMenu: () => setState(() => _currentTabIndex = 1),
                  ),

                  // 4: Profil
                  const CustomerProfileTab(),
                ],
              ),

              // Floating Bottom Navigation Bar (Dock)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomerBottomNav(
                  currentIndex: _currentTabIndex,
                  onTap: _onNavTap,
                  cartItemCount: cart.totalItemsCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
