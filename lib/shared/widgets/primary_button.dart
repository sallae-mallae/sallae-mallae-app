import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isLoading
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _PrimaryButtonContent(
                  key: const ValueKey('content'),
                  label: label,
                  icon: icon,
                ),
        ),
      ),
    );
  }
}

class _PrimaryButtonContent extends StatelessWidget {
  const _PrimaryButtonContent({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
