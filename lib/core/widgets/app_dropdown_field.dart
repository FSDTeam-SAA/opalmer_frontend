import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_input_style.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final String? hintText;
  final Widget? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  const AppDropdownField({
    super.key,
    this.value,
    this.hintText,
    this.prefixIcon,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      focusColor: AppColors.primaryVeryLight,
      hoverColor: AppColors.primaryVeryLight,
      buttonTheme: Theme.of(
        context,
      ).buttonTheme.copyWith(alignedDropdown: true),
    ),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(AppInputStyle.radius),
      menuMaxHeight: 320,
      elevation: 2,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 22,
        color: AppInputStyle.placeholder,
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(hintText: hintText, prefixIcon: prefixIcon),
    ),
  );
}
