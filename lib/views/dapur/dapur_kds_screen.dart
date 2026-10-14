import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../auth/login_screen.dart';
import 'dapur_sold_out_screen.dart';

class DapurKdsScreen extends StatefulWidget {
  const DapurKdsScreen({super.key});

  @override
  State<DapurKdsScreen> createState() => _DapurKdsScreenState();
}

class _DapurKdsScreenState extends State<DapurKdsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  Color _getTimerColor(int elapsedMinutes) {
    if (elapsedMinutes < 8) {
      return AppColors.matchaGreen; // Safe
    } else if (elapsedMinutes < 15) {
      return AppColors.amberOrange; // Warning
    }
    return AppColors.berryRed; // Overdue
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final timeFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      backgroundColor: AppColors.softSand, // Matches other pages (Warm Sand / Oat)
      appBar: AppBar(
        backgroundColor: AppColors.darkCoffeeHeader, // Matches other pages (Dark Coffee)
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.soup_kitchen_rounded, color: AppColors.activePillCream, size: 20),
            const SizedBox(width: 8),
            Text(
              'Dapur & Barista',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Compact Live Clock & Online Status
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.matchaGreen, size: 7),
                const SizedBox(width: 5),
                Text(
                  timeFormat.format(_currentTime),
                  style: GoogleFonts.courierPrime(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Bell sound alert toggle
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: orderProvider.soundEnabled ? 'Lonceng Aktif' : 'Lonceng Mati',
            icon: Icon(
              orderProvider.soundEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: orderProvider.soundEnabled ? AppColors.activePillCream : Colors.white54,
              size: 20,
            ),
            onPressed: () => orderProvider.toggleSoundAlert(),
          ),

          // Mode 86: Sold out manager
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Kelola Menu Habis (Mode 86)',
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.amberOrange, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DapurSoldOutScreen()),
              );
            },
          ),

          // Logout
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.activePillCream,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            Tab(text: '🔥 BARU (${orderProvider.newKitchenOrders.length})'),
            Tab(text: '🍳 PROSES (${orderProvider.inProgressKitchenOrders.length})'),
            Tab(text: '✅ SIAP (${orderProvider.readyKitchenOrders.length})'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersGrid(context, orderProvider.newKitchenOrders, orderProvider, 'pending'),
              _buildOrdersGrid(context, orderProvider.inProgressKitchenOrders, orderProvider, 'diproses'),
              _buildOrdersGrid(context, orderProvider.readyKitchenOrders, orderProvider, 'siap'),
            ],
          ),

          // Audio-Visual New Order Floating Overlay Banner
          if (orderProvider.incomingAlertOrder != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.darkCoffeeHeader,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppColors.activePillCream, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🔔 PESANAN BARU MASUK!',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Atas Nama: Kak ${orderProvider.incomingAlertOrder!.customerName?.isNotEmpty == true ? orderProvider.incomingAlertOrder!.customerName : "Pelanggan"} • ${orderProvider.incomingAlertOrder!.items.length} Menu',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.creamLatte,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activePillCream,
                          foregroundColor: AppColors.espressoDark,
                        ),
                        onPressed: () {
                          orderProvider.dismissAlert();
                          _tabController.animateTo(0);
                        },
                        child: const Text('Lihat Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid(
    BuildContext context,
    List<OrderModel> orders,
    OrderProvider provider,
    String stage,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2DCD5)),
              ),
              child: Icon(
                stage == 'pending'
                    ? Icons.check_circle_outline_rounded
                    : (stage == 'diproses' ? Icons.soup_kitchen_outlined : Icons.done_all_rounded),
                size: 48,
                color: AppColors.roastedCoffee.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              stage == 'pending'
                  ? 'Tidak ada antrean pesanan baru'
                  : (stage == 'diproses' ? 'Tidak ada pesanan sedang dimasak' : 'Belum ada pesanan yang siap'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan baru dari kasir akan otomatis muncul di sini.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          // Smartphone single column wireframe scroll
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildTicketCard(context, orders[index], provider, stage);
            },
          );
        }

        // Tablet / wider screen multi-column grid
        final crossAxisCount = constraints.maxWidth > 950 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildTicketCard(context, orders[index], provider, stage);
          },
        );
      },
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    OrderModel order,
    OrderProvider provider,
    String stage,
  ) {
    final elapsedMinutes = order.elapsedMinutes;
    final timerColor = _getTimerColor(elapsedMinutes);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: elapsedMinutes >= 15 ? AppColors.berryRed : const Color(0xFFE2DCD5),
          width: elapsedMinutes >= 15 ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ticket Header (Dark Coffee Brown with customer name)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.darkCoffeeHeader,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.coffee_rounded,
                        color: AppColors.creamLatte,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'KAK ${order.customerName?.toUpperCase() ?? "PELANGGAN"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Elapsed Timer Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: timerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        order.elapsedTimeString,
                        style: GoogleFonts.courierPrime(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order Subheader (Invoice & Total Items)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.invoiceNumber,
                  style: GoogleFonts.courierPrime(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.activePillCream,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${order.items.length} Menu',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.espressoDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Catatan Tamu (If any)
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // Soft warm cream
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 14, color: AppColors.amberOrange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Catatan: ${order.notes}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(color: Color(0xFFECE7E1), height: 16),

          // Items Checklist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      provider.toggleItemChecklist(order.id, item.id, item.isCompleted);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: item.isCompleted ? const Color(0xFFF9FAFB) : const Color(0xFFFAFAF9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item.isCompleted ? const Color(0xFFE5E7EB) : const Color(0xFFEFECE6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: item.isCompleted ? AppColors.matchaGreen : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.productName}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: item.isCompleted ? AppColors.textMuted : AppColors.espressoDark,
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Highlighted Modifier Notes
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Container(
                              margin: const EdgeInsets.only(left: 30),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7), // Warm yellow/cream highlight
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF92400E)),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      item.notes!.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: SizedBox(
              height: 46,
              child: _buildActionButton(stage, order, provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String stage, OrderModel order, OrderProvider provider) {
    if (stage == 'pending') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.roastedCoffee,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await provider.updateStatus(order.id, 'diproses');
        },
        icon: const Icon(Icons.soup_kitchen_rounded, size: 18),
        label: Text(
          'TERIMA & MULAI PROSES',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      );
    } else if (stage == 'diproses') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.matchaGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await provider.updateStatus(order.id, 'siap');
        },
        icon: const Icon(Icons.check_circle_rounded, size: 18),
        label: Text(
          'PESANAN SELESAI (SIAP DIPANGGIL)',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      );
    } else {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coldBrewBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await provider.updateStatus(order.id, 'selesai');
        },
        icon: const Icon(Icons.done_all_rounded, size: 18),
        label: Text(
          'SUDAH DIAMBIL PELANGGAN',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      );
    }
  }
}
