// قراءة الأرقام من حقول الإدخال: لوحة المفاتيح العربية تكتب "٣" و"٢٫٥"، وقراءتها
// مباشرة تفشل. null يعني أن النص ليس رقماً، حتى يظهر خطأ بدل حفظ صفر بصمت.
String _toLatinDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.trim().runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      out.writeCharCode(0x30 + rune - 0x0660); // ٠-٩
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      out.writeCharCode(0x30 + rune - 0x06F0); // ۰-۹
    } else if (rune == 0x066B || rune == 0x060C || rune == 0x2C) {
      out.write('.'); // ٫ ، ,
    } else if (rune == 0x2212) {
      out.write('-'); // −
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

double? parseAmount(String input) => double.tryParse(_toLatinDigits(input));

int? parseWholeNumber(String input) => int.tryParse(_toLatinDigits(input));

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
