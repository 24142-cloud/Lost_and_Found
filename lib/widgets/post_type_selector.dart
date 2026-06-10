import 'package:flutter/material.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';

class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SegmentedButton<String>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.card;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.text;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.border),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      segments: [
        ButtonSegment(
          value: 'lost',
          icon: const Icon(Icons.search_rounded),
          label: Text(l.text('lost')),
        ),
        ButtonSegment(
          value: 'found',
          icon: const Icon(Icons.inventory_2_outlined),
          label: Text(l.text('found')),
        ),
      ],
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
