enum AuthStatus { initial, loading, success, failure }

class AuthState {
  const AuthState({this.status = AuthStatus.initial, this.message});

  final AuthStatus status;
  final String? message;
}
