import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

enum LoadStatus { loading, loaded, error }

/// Central state holder for expenses: fetches, filters, and exposes
/// derived data (monthly total, category breakdown) to the UI.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  StreamSubscription<List<Expense>>? _subscription;

  List<Expense> _all = [];
  LoadStatus status = LoadStatus.loading;
  String? errorMessage;

  // --- filter state ---
  String? categoryFilter; // null = all categories
  DateTimeRange? dateRangeFilter; // null = all time
  String searchQuery = '';

  String? _uid;

  void init(String uid) {
    _uid = uid;
    status = LoadStatus.loading;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _service.streamExpenses(uid).listen(
      (data) {
        _all = data;
        status = LoadStatus.loaded;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        status = LoadStatus.error;
        errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  List<Expense> get all => _all;

  /// Applies category, date-range, and search filters together.
  List<Expense> get filtered {
    return _all.where((e) {
      if (categoryFilter != null && e.category != categoryFilter) {
        return false;
      }
      if (dateRangeFilter != null) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        final start = DateTime(dateRangeFilter!.start.year,
            dateRangeFilter!.start.month, dateRangeFilter!.start.day);
        final end = DateTime(dateRangeFilter!.end.year,
            dateRangeFilter!.end.month, dateRangeFilter!.end.day);
        if (d.isBefore(start) || d.isAfter(end)) return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchesTitle = e.title.toLowerCase().contains(q);
        final matchesNote = (e.note ?? '').toLowerCase().contains(q);
        if (!matchesTitle && !matchesNote) return false;
      }
      return true;
    }).toList();
  }

  double get currentMonthTotal {
    final now = DateTime.now();
    return _all
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Category -> total amount, for the current month (used by the chart).
  Map<String, double> get currentMonthCategoryTotals {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (final e in _all) {
      if (e.date.year == now.year && e.date.month == now.month) {
        totals.update(e.category, (v) => v + e.amount,
            ifAbsent: () => e.amount);
      }
    }
    return totals;
  }

  void setCategoryFilter(String? category) {
    categoryFilter = category;
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    dateRangeFilter = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    categoryFilter = null;
    dateRangeFilter = null;
    searchQuery = '';
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    if (_uid == null) return;
    final expense = Expense(
      uid: _uid!,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    await _service.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _service.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _service.deleteExpense(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

