import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

class FilterBar extends StatelessWidget {
  final TodoFilter filter;
  final String? priorityFilter;
  final String? categoryFilter;
  final ValueChanged<TodoFilter> onFilterChanged;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback? onClearFilters;

  const FilterBar({
    super.key,
    required this.filter,
    this.priorityFilter,
    this.categoryFilter,
    required this.onFilterChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = filter != TodoFilter.all ||
        priorityFilter != null ||
        categoryFilter != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  '全部',
                  filter == TodoFilter.all,
                  () => onFilterChanged(TodoFilter.all),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  '进行中',
                  filter == TodoFilter.active,
                  () => onFilterChanged(TodoFilter.active),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  '已完成',
                  filter == TodoFilter.completed,
                  () => onFilterChanged(TodoFilter.completed),
                ),
                const SizedBox(width: 16),
                // Priority dropdown
                _buildDropdown(
                  context,
                  '优先级',
                  priorityFilter,
                  {'high': '高', 'medium': '中', 'low': '低'},
                  onPriorityChanged,
                ),
                const SizedBox(width: 8),
                // Category dropdown
                _buildDropdown(
                  context,
                  '分类',
                  categoryFilter,
                  {
                    'general': '通用',
                    'work': '工作',
                    'personal': '个人',
                    'study': '学习',
                    'other': '其他'
                  },
                  onCategoryChanged,
                ),
              ],
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('清除筛选'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String hint,
    String? value,
    Map<String, String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hint),
      underline: const SizedBox(),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('全部$hint'),
        ),
        ...items.entries.map(
          (e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
