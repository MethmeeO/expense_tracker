import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...ExpenseCategories.values];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              category == 'All' ? selected == null : selected == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelected(category == 'All' ? null : category),
          );
        },
      ),
    );
  }
}
