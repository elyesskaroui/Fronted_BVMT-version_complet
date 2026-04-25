import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/local_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    await Future.delayed(const Duration(seconds: 1));  
    
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Veuillez remplir tous les champs',
      ));
      return;
    }

    if (!event.email.contains('@')) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Adresse email invalide',
      ));
      return;
    }

    if (event.password.length < 6) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Le mot de passe doit contenir au moins 6 caractères',
      ));
      return;
    }

    // Mock : connexion réussie
    final userName = event.email.split('@').first;
    sl<LocalStorageService>().setLoggedIn(userName);
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userName: userName,
    ));
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 1));

    if (event.fullName.isEmpty || event.email.isEmpty || event.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Veuillez remplir tous les champs',
      ));
      return;
    }

    if (!event.email.contains('@')) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Adresse email invalide',
      ));
      return;
    }

    if (event.password.length < 6) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Le mot de passe doit contenir au moins 6 caractères',
      ));
      return;
    }

    // Mock : inscription réussie
    sl<LocalStorageService>().setLoggedIn(event.fullName);
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userName: event.fullName,
    ));
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    sl<LocalStorageService>().setLoggedOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
