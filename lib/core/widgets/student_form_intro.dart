import 'package:flutter/material.dart';

import '../app_theme.dart';

class StudentFormIntro extends StatelessWidget {
  const StudentFormIntro({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.paleBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.person_add_alt_1_rounded, size: 32, color: AppTheme.blue),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New student',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Enter the student details below.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
