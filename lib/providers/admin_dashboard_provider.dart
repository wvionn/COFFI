import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class AdminDashboardProvider extends ChangeNotifier {
  String _selectedPeriod = 'Hari Ini'; // 'Hari Ini', 'Kemarin', '7 Hari Terakhir', 'Bulan Ini'

  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Filter orders based on period
  List<OrderModel> getFilteredOrders(List<OrderModel> allOrders) {
    final now = DateTime.now();
    return allOrders.where((order) {
      if (order.isCancelled) return false;

      final diff = now.difference(order.createdAt);
      if (_selectedPeriod == 'Hari Ini') {
        return order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day;
      } else if (_selectedPeriod == 'Kemarin') {
        final yesterday = now.subtract(const Duration(days: 1));
        return order.createdAt.year == yesterday.year &&
            order.createdAt.month == yesterday.month &&
            order.createdAt.day == yesterday.day;
      } else if (_selectedPeriod == '7 Hari Terakhir') {
        return diff.inDays <= 7;
      } else if (_selectedPeriod == 'Bulan Ini') {
        return order.createdAt.year == now.year && order.createdAt.month == now.month;
      }
      return true;
    }).toList();
  }

  double calculateTotalOmset(List<OrderModel> orders) {
    return orders.fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double calculateTotalHpp(List<OrderModel> orders) {
    return orders.fold(0.0, (sum, o) => sum + o.totalHpp);
  }

  double calculateGrossProfit(List<OrderModel> orders) {
    return calculateTotalOmset(orders) - calculateTotalHpp(orders);
  }

  double calculateAverageMargin(List<OrderModel> orders) {
    final omset = calculateTotalOmset(orders);
    if (omset <= 0) return 0.0;
    return (calculateGrossProfit(orders) / omset) * 100;
  }

  double calculateAverageOrderValue(List<OrderModel> orders) {
    if (orders.isEmpty) return 0.0;
    return calculateTotalOmset(orders) / orders.length;
  }

  Map<String, int> getTopSellingItems(List<OrderModel> orders) {
    final Map<String, int> counts = {};
    for (final order in orders) {
      for (final item in order.items) {
        counts[item.productName] = (counts[item.productName] ?? 0) + item.quantity;
      }
    }
    final sortedEntries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(5));
  }
}
