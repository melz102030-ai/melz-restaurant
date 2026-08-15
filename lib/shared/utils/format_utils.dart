// تنسيق موحّد للعدّاد التنازلي (وقت التحضير المتبقي) — يُستخدم في شاشات
// المطبخ والمندوب وتتبع الطلب للعميل، حتى لا تختلف الصياغة بين شاشة وأخرى
String formatCountdown(Duration d) {
  if (d.isNegative) {
    final over = d.abs();
    return 'تأخر ${over.inMinutes} د ${over.inSeconds % 60} ث';
  }
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
