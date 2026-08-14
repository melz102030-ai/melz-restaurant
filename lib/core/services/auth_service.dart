import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colUsers = 'users';

  // ─── تطبيع رقم الجوال إلى صيغة موحّدة بغض النظر عن كيفية كتابته ─────────────
  // يقبل: 05XXXXXXXX، 5XXXXXXXX، 966XXXXXXXXX، +966 5XXXXXXXX ... إلخ
  static String normalizePhone(String countryCode, String rawInput) {
    final ccDigits = countryCode.replaceAll(RegExp(r'\D'), '');
    var digits = rawInput.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(ccDigits) && ccDigits.isNotEmpty) {
      return digits;
    }
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    return '$ccDigits$digits';
  }

  static String _pseudoEmail(String normalizedPhone) =>
      '$normalizedPhone@meals.local';

  // ─── إنشاء حساب عميل برقم جوال + كلمة مرور ───────────────────────────────
  static Future<UserModel> signUpWithPhonePassword(
    String countryCode,
    String rawPhone,
    String password,
    String name,
  ) async {
    final normalized = normalizePhone(countryCode, rawPhone);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: _pseudoEmail(normalized),
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('فشل إنشاء الحساب');

    final user = UserModel(
      id: firebaseUser.uid,
      phone: normalized,
      name: name.trim().isEmpty ? 'عميل' : name.trim(),
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    await _db.collection(_colUsers).doc(firebaseUser.uid).set(user.toMap());
    return user;
  }

  // ─── تسجيل الدخول برقم الجوال + كلمة المرور ──────────────────────────────
  static Future<UserModel> loginWithPhonePassword(
    String countryCode,
    String rawPhone,
    String password,
  ) async {
    final normalized = normalizePhone(countryCode, rawPhone);
    final credential = await _auth.signInWithEmailAndPassword(
      email: _pseudoEmail(normalized),
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('فشل تسجيل الدخول');
    return await _getOrCreateUser(firebaseUser, normalized);
  }

  static String phonePasswordError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'رقم الجوال أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'يوجد حساب مسجّل بهذا الرقم مسبقاً، سجّل الدخول بدلاً من ذلك';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، اختر كلمة مرور أطول';
      case 'invalid-email':
        return 'رقم الجوال غير صحيح';
      case 'too-many-requests':
        return 'طلبات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'خطأ: $code';
    }
  }

  // ─── إنشاء أو جلب مستخدم من Firestore ────────────────────────────────────
  static Future<UserModel> _getOrCreateUser(User firebaseUser,
      [String? phone]) async {
    final doc = await _db.collection(_colUsers).doc(firebaseUser.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    final user = UserModel(
      id: firebaseUser.uid,
      phone: phone ?? firebaseUser.phoneNumber ?? '',
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
    // أولاً: تحقق من Firebase Auth الحالي
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final doc = await _db.collection(_colUsers).doc(firebaseUser.uid).get();
        if (doc.exists) {
          final user = UserModel.fromMap(doc.data()!, doc.id);
          await saveSession(user); // حدّث الكاش المحلي بأحدث بيانات
          return user;
        }
      } catch (_) {}
    }

    // ثانياً: من SharedPreferences مع التحقق من Firestore
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;

    // حاول جلب أحدث بيانات من Firestore (يلتقط تغييرات الأدمن على الدور)
    try {
      final doc = await _db.collection(_colUsers).doc(id).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        await saveSession(user);
        return user;
      }
    } catch (_) {}

    // الاحتياطي الأخير: الكاش المحلي فقط (لا اتصال)
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
    // استخدم set+merge بدلاً من update حتى يعمل حتى لو لم يكن الـ document موجوداً
    await _db.collection(_colUsers).doc(userId).set(
      {'name': name},
      SetOptions(merge: true),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // يحفظ موقع التوصيل الافتراضي للعميل — يُستخدم تلقائياً في المرات القادمة حتى يغيّره
  static Future<void> updateSavedLocation(
    String userId, {
    required double lat,
    required double lng,
    String? address,
  }) async {
    await _db.collection(_colUsers).doc(userId).set(
      {'savedLat': lat, 'savedLng': lng, 'savedAddress': address},
      SetOptions(merge: true),
    );
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

  // ─── دخول مباشر بدون كلمة مرور (لمرحلة المعاينة فقط) ─────────────────────
  static const Map<UserRole, String> _quickLoginNames = {
    UserRole.customer: 'عميل تجريبي',
    UserRole.admin: 'مدير النظام',
    UserRole.kitchen: 'موظف مطبخ',
    UserRole.driver: 'مندوب توصيل',
  };

  static Future<UserModel> quickPreviewLogin(UserRole role) async {
    String uid = 'dev_${role.name}';
    try {
      final anonResult = await _auth.signInAnonymously();
      if (anonResult.user != null) uid = anonResult.user!.uid;
    } catch (_) {
      // Anonymous Auth غير مفعّل — نكمل بـ uid ثابت
    }

    final user = UserModel(
      id: uid,
      phone: 'dev_${role.name}',
      name: _quickLoginNames[role]!,
      role: role,
      createdAt: DateTime.now(),
    );

    try {
      await _db
          .collection(_colUsers)
          .doc(uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (_) {}

    return user;
  }

  // إنشاء موظف مباشرة من الأدمن — يُنشئ حساب Firebase Auth حقيقياً (بنفس نمط
  // البريد الوهمي المستخدم لعملاء الجوال/كلمة المرور) عبر تطبيق Firebase مؤقت
  // منفصل، حتى لا تُستبدل جلسة الأدمن الحالي بجلسة الموظف الجديد فور إنشائه.
  // يسجّل الموظف دخوله لاحقاً عبر /staff-login بنفس رقمه وكلمة المرور هذه.
  static Future<UserModel> createStaffUser(
      String phone, String name, UserRole role, String password) async {
    final tempApp = await Firebase.initializeApp(
      name: 'staffCreate_${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: _pseudoEmail(phone),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('فشل إنشاء حساب الموظف');

      final user = UserModel(
        id: firebaseUser.uid,
        phone: phone,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );
      await _db.collection(_colUsers).doc(firebaseUser.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('يوجد موظف مسجّل بهذا الرقم مسبقاً');
      }
      throw Exception(phonePasswordError(e.code));
    } finally {
      await tempApp.delete();
    }
  }

  // ─── دخول فريق العمل (أدمن/مطبخ/مندوب) برقم الجوال + كلمة المرور ─────────
  static Future<UserModel> loginStaff(String phone, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: _pseudoEmail(phone),
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('فشل تسجيل الدخول');
    final doc = await _db.collection(_colUsers).doc(firebaseUser.uid).get();
    if (!doc.exists) throw Exception('بيانات الموظف غير موجودة');
    final user = UserModel.fromMap(doc.data()!, doc.id);
    if (user.role == UserRole.customer) {
      await _auth.signOut();
      throw Exception('هذا الحساب ليس من فريق العمل');
    }
    return user;
  }

  // ─── المناديب ─────────────────────────────────────────────────────────────
  static Stream<List<UserModel>> streamDrivers() {
    return _db
        .collection(_colUsers)
        .where('role', isEqualTo: UserRole.driver.name)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<void> setDriverAvailability(String driverId, bool isAvailable) async {
    await _db
        .collection(_colUsers)
        .doc(driverId)
        .set({'isAvailable': isAvailable}, SetOptions(merge: true));
  }
}
