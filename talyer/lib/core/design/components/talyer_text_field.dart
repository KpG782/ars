import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Labelled text field. The visible [label] is also wired as the field's
/// accessibility label, and errors render close to the input.
class TalyerTextField extends StatelessWidget {
  const TalyerTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.onChanged,
    this.helper,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? errorText;
  final String? helper;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TalyerType.titleSmall.copyWith(color: t.text2)),
        const SizedBox(height: TalyerSpacing.x2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TalyerType.bodyLarge.copyWith(color: t.text1),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: t.text3) : null,
            suffixIcon: suffix,
          ),
        ),
        if (helper != null && errorText == null) ...[
          const SizedBox(height: TalyerSpacing.x1),
          Text(helper!, style: TalyerType.caption.copyWith(color: t.text3)),
        ],
      ],
    );
  }
}
