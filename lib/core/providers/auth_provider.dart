import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  // المستخدم المبدئي يُمرَّر من main() بعد تحميل الجلسة قبل runApp
  AuthNotifier([UserModel? initialUser]) : super(initialUser) {
    if (initialUser != null) _startUserStream(initialUser.id);
  }

  StreamSubscription<UserModel?>? _userSub;

  // يبدأ الاستماع لوثيقة المستخدم في Firestore —
  // أي تغيير في الصلاحيات أو الدور يُحدِّث الـ state فوراً دون إعادة تسجيل دخول
  void _startUserStream(String userId) {
    _userSub?.cancel();
    _userSub = AuthService.streamUserById(userId).listen((user) {
      if (user != null) state = user;
    });
  }

  void _stopUserStream() {
    _userSub?.cancel();
    _userSub = null;
  }

  Future<void> login(UserModel user) async {
    await AuthService.saveSession(user);
    state = user;
    _startUserStream(user.id);
  }

  Future<void> logout() async {
    _stopUserStream();
    await AuthService.logout();
    state = null;
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    await AuthService.updateUserName(state!.id, name);
    // لا نُحدِّث state يدوياً — stream Firestore سيلتقطه تلقائياً
  }

  void updatePermissions(Map<String, bool> permissions) {
    if (state == null) return;
    state = state!.copyWith(permissions: permissions);
  }

  @override
  void dispose() {
    _stopUserStream();
    super.dispose();
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
