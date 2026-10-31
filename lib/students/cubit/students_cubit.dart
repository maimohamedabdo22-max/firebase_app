import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit() : super(const StudentsState());
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void watchStudents() {
    emit(const StudentsState(status: StudentsStatus.loading));
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('students')
        .snapshots()
        .listen(
          (snapshot) => emit(
            StudentsState(
              status: StudentsStatus.loaded,
              students: snapshot.docs,
            ),
          ),
          onError: (Object error) => emit(
            StudentsState(
              status: StudentsStatus.failure,
              message: error.toString(),
            ),
          ),
        );
  }

  Future<void> addStudent({
    required String name,
    required String age,
    required String grade,
  }) async {
    await FirebaseFirestore.instance.collection('students').add({
      'name': name.trim(),
      'age': age.trim(),
      'grade': grade.trim(),
    });
  }

  Future<void> updateStudent({
    required String id,
    required String name,
    required String age,
    required String grade,
  }) async {
    await FirebaseFirestore.instance.collection('students').doc(id).update({
      'name': name.trim(),
      'age': age.trim(),
      'grade': grade.trim(),
    });
  }

  Future<void> deleteStudent(String id) =>
      FirebaseFirestore.instance.collection('students').doc(id).delete();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
