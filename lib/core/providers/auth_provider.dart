import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await AuthService.loadSession();
    state = user;
  }

  Future<void> login(UserModel user) async {
    await AuthService.saveSession(user);
    state = user;
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = null;
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    await AuthService.updateUserName(state!.id, name);
    state = state!.copyWith(name: name);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider)?.role;
});
