// هاتف المدير الأساسي مُضمَّن في الكود عمداً — لا يمكن لأحد (حتى قاعدة
// البيانات) أن يسقط صلاحيته أو يتلاعب بها؛ هذا ضمان أمني أساسي يتجاوز
// أي تغيير يطرأ على Firestore. الهاتف يُطابَق بعد توحيده فقط (أرقام فقط).
abstract class SystemAdmins {
  static const String _superAdminPhone = '0531131125';

  static bool isSuperAdmin(String phone) =>
      _normalize(phone) == _normalize(_superAdminPhone);

  static String _normalize(String p) =>
      p.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^966'), '0');
}
