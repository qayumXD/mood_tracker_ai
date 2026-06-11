import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 50,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                ),
                side: const BorderSide(color: AppColors.primary, width: 2),
              ),
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : icon != null
                      ? Icon(icon)
                      : const SizedBox.shrink(),
              label: Text(label),
            )
          : FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : icon != null
                      ? Icon(icon)
                      : const SizedBox.shrink(),
              label: Text(label),
            ),
    );
  }
}