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

  return Container(
    height: 60,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F5F2),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppColors.border.withOpacity(0.7),
      ),
    ),
    child: Row(
      children: [
        _ModernTypeButton(
          selected: value == 'lost',
          label: l.text('lost'),
          icon: Icons.search_rounded,
          activeColor: const Color(0xFFE15C4F),
          onTap: () => onChanged('lost'),
        ),
        const SizedBox(width: 6),
        _ModernTypeButton(
          selected: value == 'found',
          label: l.text('found'),
          icon: Icons.inventory_2_rounded,
          activeColor: const Color(0xFF3FA46A),
          onTap: () => onChanged('found'),
        ),
      ],
    ),
  );
}
}

class _ModernTypeButton extends StatelessWidget {
  const _ModernTypeButton({
    required this.selected,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: selected ? 1.02 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? Colors.white
                          : AppColors.subtext,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}