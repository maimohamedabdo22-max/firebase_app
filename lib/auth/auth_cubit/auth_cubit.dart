import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> login(String email, String password) => _run(
    () => FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<void> signUp(String email, String password) => _run(
    () => FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<void> _run(Future<UserCredential> Function() action) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await action();
      emit(const AuthState(status: AuthStatus.success));
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' || 'invalid-credential' => 'Wrong email or password',
        'email-already-in-use' => 'This email is already registered',
        'invalid-email' => 'Invalid email',
        'weak-password' => 'Password is too weak',
        _ => error.message ?? 'Something went wrong. Please try again.',
      };
      emit(AuthState(status: AuthStatus.failure, message: message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
