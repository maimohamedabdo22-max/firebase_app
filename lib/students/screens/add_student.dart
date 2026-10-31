import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/students_cubit.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/student_form_intro.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final gradeController = TextEditingController();

  bool isLoading = false;

  Future<void> addStudent() async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        gradeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all data')));

      return;
    }

    setState(() => isLoading = true);

    try {
      await context.read<StudentsCubit>().addStudent(
        name: nameController.text,
        age: ageController.text,
        grade: gradeController.text,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    gradeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add student')),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StudentFormIntro(),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: nameController,
                    label: 'Full name',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 12),

                  AppTextField(
                    controller: ageController,
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  AppTextField(
                    controller: gradeController,
                    label: 'Grade',
                    icon: Icons.class_outlined,
                  ),

                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: 'Save student',
                    onPressed: addStudent,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
