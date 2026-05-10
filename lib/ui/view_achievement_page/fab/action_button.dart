import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final double radius;

  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
    this.radius = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: color ?? theme.colorScheme.secondary,
      elevation: 4.0,
      child: SizedBox(
        width: radius,
        height: radius,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}
