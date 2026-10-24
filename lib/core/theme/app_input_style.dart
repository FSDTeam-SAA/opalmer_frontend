import 'package:flutter/material.dart';
import 'app_colors.dart';

/// One surface and outline for text, search, multiline and form selection fields.
class AppInputStyle {
  static const background = Color(0xFFF7F7FA);
  static const outline = Color(0xFFE4E2EA);
  static const placeholder = Color(0xFF93909F);
  static const radius = 12.0;

  static OutlineInputBorder border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );

  static InputDecorationTheme get theme => InputDecorationTheme(
    filled: true,
    fillColor: background,
    hoverColor: const Color(0xFFF3F0F7),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(outline),
    enabledBorder: border(outline),
    disabledBorder: border(const Color(0xFFECEAF0)),
    focusedBorder: border(AppColors.primaryMid, width: 1.5),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error, width: 1.5),
    hintStyle: const TextStyle(
      color: placeholder,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    floatingLabelStyle: const TextStyle(
      color: AppColors.primaryMid,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    helperStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
    prefixIconColor: placeholder,
    suffixIconColor: placeholder,
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    alignLabelWithHint: true,
  );
}
