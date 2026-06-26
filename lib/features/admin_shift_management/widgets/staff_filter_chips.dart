import 'package:flutter/material.dart';

class StaffFilterChips extends StatelessWidget {
  const StaffFilterChips({
    required this.allStaff,
    required this.selectedStaffIds,
    required this.onChanged,
    super.key,
  });

  final List<Map<String, Object?>> allStaff;
  final List<int>? selectedStaffIds;
  final ValueChanged<List<int>?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Tất cả'),
            selected: selectedStaffIds == null,
            onSelected: (_) => onChanged(null),
          ),
          ...allStaff.map((staff) {
            final id = staff['id'] as int;
            final name = staff['full_name'] as String? ?? 'Unknown';
            final isSelected = selectedStaffIds?.contains(id) ?? false;

            return FilterChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (_) {
                if (selectedStaffIds == null) {
                  onChanged([id]);
                } else {
                  final newSelection = List<int>.from(selectedStaffIds!);
                  if (isSelected) {
                    newSelection.remove(id);
                    onChanged(newSelection.isEmpty ? null : newSelection);
                  } else {
                    newSelection.add(id);
                    onChanged(newSelection);
                  }
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
