import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentsStatus { initial, loading, loaded, failure }

class StudentsState {
  const StudentsState({
    this.status = StudentsStatus.initial,
    this.students = const [],
    this.message,
  });

  final StudentsStatus status;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> students;
  final String? message;
}
