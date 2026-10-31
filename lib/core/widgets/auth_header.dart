import 'package:flutter/material.dart';

import '../app_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 44,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.paleBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, size: iconSize, color: AppTheme.blue),
      ),
      const SizedBox(height: 26),
      Text(
        title,
        style: const TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.w800,
          color: AppTheme.navy,
        ),
      ),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
    ],
  );
}
