import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                  )
                : widget.suffixIcon != null
                    ? GestureDetector(
                        onTap: widget.onSuffixIconPressed,
                        child: Icon(widget.suffixIcon),
                      )
                    : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
