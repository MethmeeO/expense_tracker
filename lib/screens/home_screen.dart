import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/category_summary_chart.dart';
import '../widgets/expense_tile.dart';
import '../widgets/state_placeholders.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: provider.dateRangeFilter,
    );
    if (range != null) {
      provider.setDateRangeFilter(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final hasActiveFilters = provider.categoryFilter != null ||
        provider.dateRangeFilter != null ||
        provider.searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search title or note...',
                  border: InputBorder.none,
                ),
                onChanged: provider.setSearchQuery,
              )
            : const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_searching) {
                  _searchController.clear();
                  provider.setSearchQuery('');
                }
                _searching = !_searching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickDateRange(context),
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode_outlined),
            onPressed: () => themeProvider.toggle(),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (provider.status == LoadStatus.loading) {
          return const LoadingState();
        }
        if (provider.status == LoadStatus.error) {
          return ErrorState(
            message: provider.errorMessage ?? 'Unknown error',
          );
        }

        final list = provider.filtered;

        return RefreshIndicator(
          onRefresh: () async {
            // Firestore stream keeps itself live; this just gives users
            // the familiar pull-to-refresh affordance.
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _MonthTotalCard(total: provider.currentMonthTotal)),
              SliverToBoxAdapter(
                child: CategorySummaryChart(
                    categoryTotals: provider.currentMonthCategoryTotals),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CategoryFilterBar(
                    selected: provider.categoryFilter,
                    onSelected: provider.setCategoryFilter,
                  ),
                ),
              ),
              if (hasActiveFilters)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searching = false);
                          provider.clearFilters();
                        },
                        icon: const Icon(Icons.filter_alt_off, size: 18),
                        label: const Text('Clear filters'),
                      ),
                    ),
                  ),
                ),
              if (list.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = list[index];
                      return ExpenseTile(
                        expense: expense,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditExpenseScreen(existing: expense),
                          ),
                        ),
                        onDelete: () =>
                            provider.deleteExpense(expense.id!),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _MonthTotalCard extends StatelessWidget {
  final double total;
  const _MonthTotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthFormat.format(DateTime.now()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(total),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            Icon(Icons.account_balance_wallet,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}
