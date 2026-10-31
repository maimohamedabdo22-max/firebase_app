import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_student.dart';
import '../../core/app_theme.dart';
import '../cubit/students_cubit.dart';
import '../cubit/students_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/edit_student_dialog.dart';
import '../../core/widgets/student_card.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentsCubit()..watchStudents(),
      child: const _StudentsView(),
    );
  }
}

class _StudentsView extends StatelessWidget {
  const _StudentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student directory'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<StudentsCubit, StudentsState>(
        builder: (context, state) {
          if (state.status == StudentsStatus.loading ||
              state.status == StudentsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudentsStatus.failure) {
            return EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load students',
              subtitle: state.message ?? 'Check your connection and try again.',
            );
          }
          final students = state.students;
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<StudentsCubit>().watchStudents(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.navy, AppTheme.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your students',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${students.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Text(
                                      'records in your directory',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .16),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  size: 34,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'All students',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          students.isEmpty
                              ? 'Add your first student to get started.'
                              : 'Keep student details organized in one place.',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if (students.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.school_outlined,
                      title: 'No students yet',
                      subtitle: 'Tap the button below to add a student.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: students.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = students[index];
                        final data = doc.data();
                        final name = (data['name'] ?? '').toString();
                        final age = (data['age'] ?? '').toString();
                        final grade = (data['grade'] ?? '').toString();
                        return StudentCard(
                          name: name,
                          age: age,
                          grade: grade,
                          onEdit: () => _showEditDialog(
                            context,
                            doc.id,
                            name,
                            age,
                            grade,
                          ),
                          onDelete: () =>
                              _showDeleteDialog(context, doc.id, name),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StudentsCubit>(),
              child: const AddStudent(),
            ),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add student',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String id,
    String oldName,
    String oldAge,
    String oldGrade,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<StudentsCubit>(),
        child: EditStudentDialog(
          studentId: id,
          name: oldName,
          age: oldAge,
          grade: oldGrade,
        ),
      ),
    );
    if (updated == true && context.mounted) {
      _showMessage(context, 'Student updated successfully');
    }
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text(
          'This will permanently remove ${name.isEmpty ? 'this student' : name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () async {
              try {
                await context.read<StudentsCubit>().deleteStudent(id);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  _showMessage(context, 'Student deleted successfully');
                }
              } catch (_) {
                if (context.mounted) {
                  _showMessage(context, 'Could not delete student. Try again.');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
