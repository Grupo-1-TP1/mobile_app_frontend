part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class LogInEvent extends AuthEvent {
  final String email;
  final String password;

  const LogInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogOutEvent extends AuthEvent {
  const LogOutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? profileImageUrl;

  const UpdateProfileEvent({
    this.name,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, profileImageUrl];
}
