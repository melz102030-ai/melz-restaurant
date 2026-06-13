import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionUsers = 'users';
  static const String _collectionOtp = 'otp_codes';

  // Generate 6-digit OTP
  static String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // رقم واتساب مطعم ميلز الثابت
  static const String melzWhatsapp = '966565235404';

  // التحقق من وجود حساب مسبق بنفس الرقم
  static Future<bool> phoneExists(String phone) async {
    final query = await _db
        .collection(_collectionUsers)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // إرسال OTP عبر واتساب الشخصي للعميل (يفتح محادثة مع ميلز)
  static Future<String> sendOtp(String phone, [String? ignored]) async {
    final otp = _generateOtp();
    final expiry = DateTime.now().add(const Duration(minutes: 5));

    // حفظ OTP في Firestore
    await _db.collection(_collectionOtp).doc(phone).set({
      'otp': otp,
      'phone': phone,
      'expiry': Timestamp.fromDate(expiry),
      'used': false,
    });

    // فتح واتساب العميل ويكتب الرسالة تلقائياً لرقم ميلز (بدون إرسال)
    final message = 'كود : $otp';
    final encodedMsg = Uri.encodeComponent(message);
    final waUrl = 'https://wa.me/$melzWhatsapp?text=$encodedMsg';

    final uri = Uri.parse(waUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return otp;
  }

  // Verify OTP
  static Future<bool> verifyOtp(String phone, String enteredOtp) async {
    final doc = await _db.collection(_collectionOtp).doc(phone).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final storedOtp = data['otp'] as String;
    final expiry = (data['expiry'] as Timestamp).toDate();
    final used = data['used'] as bool;

    if (used) return false;
    if (DateTime.now().isAfter(expiry)) return false;
    if (storedOtp != enteredOtp) return false;

    // Mark as used
    await _db.collection(_collectionOtp).doc(phone).update({'used': true});
    return true;
  }

  // Get or create user after OTP verified
  static Future<UserModel> getOrCreateUser(String phone) async {
    final query = await _db
        .collection(_collectionUsers)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
    }

    // Create new customer user
    final docRef = _db.collection(_collectionUsers).doc();
    final user = UserModel(
      id: docRef.id,
      phone: phone,
      name: 'عميل',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    await docRef.set(user.toMap());
    return user;
  }

  // Save session
  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phone', user.phone);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_role', user.role.name);
  }

  // Load session
  static Future<UserModel?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;

    final phone = prefs.getString('user_phone') ?? '';
    final name = prefs.getString('user_name') ?? '';
    final roleStr = prefs.getString('user_role') ?? 'customer';

    return UserModel(
      id: id,
      phone: phone,
      name: name,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.now(),
    );
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Update user name
  static Future<void> updateUserName(String userId, String name) async {
    await _db.collection(_collectionUsers).doc(userId).update({'name': name});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // Get all users (admin)
  static Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection(_collectionUsers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Change user role (admin)
  static Future<void> changeUserRole(String userId, UserRole role) async {
    await _db.collection(_collectionUsers).doc(userId).update({'role': role.name});
  }
}
