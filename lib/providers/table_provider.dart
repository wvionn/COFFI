import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/table_model.dart';
import '../services/supabase_service.dart';

class TableProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<TableModel> _tables = [];
  bool _isLoading = false;
  String _selectedAreaFilter = 'Semua Area';
  StreamSubscription? _tablesSubscription;

  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;
  String get selectedAreaFilter => _selectedAreaFilter;

  int get totalTables => _tables.length;
  int get availableTablesCount => _tables.where((t) => t.isAvailable).length;
  int get occupiedTablesCount => _tables.where((t) => t.isOccupied).length;

  List<String> get availableAreas {
    final areas = _tables.map((t) => t.area).toSet().toList();
    areas.sort();
    return ['Semua Area', ...areas];
  }

  List<TableModel> get filteredTables {
    if (_selectedAreaFilter == 'Semua Area') {
      return _tables;
    }
    return _tables.where((t) => t.area.toLowerCase() == _selectedAreaFilter.toLowerCase()).toList();
  }

  TableProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _tables = await _service.fetchTables();
    _isLoading = false;
    notifyListeners();

    _tablesSubscription?.cancel();
    _tablesSubscription = _service.tablesStream.listen((updatedList) {
      _tables = updatedList;
      notifyListeners();
    });
  }

  void setAreaFilter(String area) {
    _selectedAreaFilter = area;
    notifyListeners();
  }

  Future<bool> addTable({
    required String tableNumber,
    String area = 'Indoor',
    int capacity = 4,
  }) async {
    final success = await _service.addTable(
      tableNumber: tableNumber,
      area: area,
      capacity: capacity,
    );
    if (success) {
      await _service.fetchTables();
    }
    return success;
  }

  Future<int> autoGenerateTables({
    required String prefix,
    required int startNumber,
    required int endNumber,
    String area = 'Indoor',
    int capacity = 4,
  }) async {
    final count = await _service.autoGenerateTables(
      prefix: prefix,
      startNumber: startNumber,
      endNumber: endNumber,
      area: area,
      capacity: capacity,
    );
    return count;
  }

  Future<bool> forceFreeTable(String tableId) async {
    return await _service.forceFreeTable(tableId);
  }

  @override
  void dispose() {
    _tablesSubscription?.cancel();
    super.dispose();
  }
}
