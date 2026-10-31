import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../students/cubit/students_cubit.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

class EditStudentDialog extends StatefulWidget {
  const EditStudentDialog({
    super.key,
    required this.studentId,
    required this.name,
    required this.age,
    required this.grade,
  });

  final String studentId;
  final String name;
  final String age;
  final String grade;

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _gradeController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _gradeController = TextEditingController(text: widget.grade);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final grade = _gradeController.text.trim();
    if (name.isEmpty || age.isEmpty || grade.isEmpty) {
      setState(() => _error = 'Please complete all fields.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await context.read<StudentsCubit>().updateStudent(
        id: widget.studentId,
        name: name,
        age: age,
        grade: grade,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error.code) {
          'permission-denied' =>
            'Permission denied. Check the Firestore security rules for updating students.',
          'not-found' =>
            'This student record no longer exists. Close and refresh the list.',
          _ => error.message ?? 'Could not save changes. Please try again.',
        };
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not save changes: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit student'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _gradeController,
            label: 'Grade',
            icon: Icons.class_outlined,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      SizedBox(
        width: 142,
        child: PrimaryButton(
          label: 'Save changes',
          isLoading: _isSaving,
          onPressed: _save,
        ),
      ),
    ],
  );
}
