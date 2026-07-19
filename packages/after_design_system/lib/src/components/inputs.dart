import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';

/// Text field styled to After tokens (hairline focus ring → ice accent).
class AfterTextField extends StatelessWidget {
  const AfterTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: type.labelMedium.copyWith(color: colors.muted),
          ),
          const SizedBox(height: AfterSpacing.xs),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: type.bodyMedium.copyWith(color: colors.foreground),
          cursorColor: colors.accent,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AfterRadius.smAll,
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AfterRadius.smAll,
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AfterRadius.smAll,
              borderSide: BorderSide(color: colors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AfterRadius.smAll,
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AfterRadius.smAll,
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            hintStyle: type.bodyMedium.copyWith(color: colors.subtle),
          ),
        ),
      ],
    );
  }
}

/// Search field with leading search icon.
class AfterSearchField extends StatelessWidget {
  const AfterSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    return AfterTextField(
      controller: controller,
      hint: hint,
      onChanged: onChanged,
      prefixIcon: Icon(Icons.search, color: colors.subtle, size: 20),
      suffixIcon: onClear == null
          ? null
          : IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close, color: colors.subtle, size: 18),
            ),
    );
  }
}

/// Labeled switch row.
class AfterSwitchTile extends StatelessWidget {
  const AfterSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: type.titleSmall.copyWith(color: colors.foreground)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: type.bodySmall.copyWith(color: colors.muted)),
              ],
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colors.onAccent,
          activeTrackColor: colors.accent,
        ),
      ],
    );
  }
}
