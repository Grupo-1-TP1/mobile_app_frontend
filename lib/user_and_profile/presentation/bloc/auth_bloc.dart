import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/use_cases/auth_use_cases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final LogInUseCase logInUseCase;
  final LogOutUseCase logOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthBloc({
    required this.signUpUseCase,
    required this.logInUseCase,
    required this.logOutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<LogInEvent>(_onLogIn);
    on<LogOutEvent>(_onLogOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogIn(LogInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await logInUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogOut(LogOutEvent event, Emitter<AuthState> emit) async {
    await logOutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        final currentUser = (state as AuthAuthenticated).user;
        final updatedUser = await updateProfileUseCase(
          userId: currentUser.id,
          name: event.name,
          profileImageUrl: event.profileImageUrl,
        );
        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }
}
