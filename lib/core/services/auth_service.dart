import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colUsers = 'users';

  // يُخزّن نتيجة إرسال OTP على الويب
  static ConfirmationResult? _webConfirmResult;

  // ─── إرسال OTP عبر Firebase (SMS) ────────────────────────────────────────
  static Future<void> sendOtp(String phone) async {
    _webConfirmResult = await _auth.signInWithPhoneNumber(phone);
  }

  // ─── التحقق من الكود ──────────────────────────────────────────────────────
  static Future<UserModel> verifyOtp(String code) async {
    if (_webConfirmResult == null) {
      throw Exception('لم يتم إرسال الكود بعد');
    }
    final credential = await _webConfirmResult!.confirm(code);
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('فشل التحقق');
    return await _getOrCreateUser(firebaseUser);
  }

  // ─── إنشاء أو جلب مستخدم من Firestore ────────────────────────────────────
  static Future<UserModel> _getOrCreateUser(User firebaseUser) async {
    final doc = await _db.collection(_colUsers).doc(firebaseUser.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    final user = UserModel(
      id: firebaseUser.uid,
      phone: firebaseUser.phoneNumber ?? '',
      name: 'عميل',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    await _db.collection(_colUsers).doc(firebaseUser.uid).set(user.toMap());
    return user;
  }

  // ─── الجلسة ───────────────────────────────────────────────────────────────
  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phone', user.phone);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_role', user.role.name);
  }

  static Future<UserModel?> loadSession() async {
    // أولاً: تحقق من Firebase Auth
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final doc =
            await _db.collection(_colUsers).doc(firebaseUser.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
    }
    // ثانياً: من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;
    return UserModel(
      id: id,
      phone: prefs.getString('user_phone') ?? '',
      name: prefs.getString('user_name') ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (prefs.getString('user_role') ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.now(),
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> updateUserName(String userId, String name) async {
    await _db.collection(_colUsers).doc(userId).update({'name': name});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection(_colUsers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<void> changeUserRole(String userId, UserRole role) async {
    await _db.collection(_colUsers).doc(userId).update({'role': role.name});
  }

  // إنشاء موظف مباشرة من الأدمن (بدون OTP — يسجّل لاحقاً بنفسه)
  static Future<UserModel> createStaffUser(
      String phone, String name, UserRole role) async {
    // تحقق أولاً إن كان موجوداً
    final q = await _db
        .collection(_colUsers)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) {
      final existing = UserModel.fromMap(q.docs.first.data(), q.docs.first.id);
      await changeUserRole(existing.id, role);
      return existing;
    }
    final ref = _db.collection(_colUsers).doc();
    final user = UserModel(
      id: ref.id,
      phone: phone,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
    await ref.set(user.toMap());
    return user;
  }
}
