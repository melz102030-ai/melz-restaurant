// فترة عمل واحدة (شفت) ضمن يوم — HH:mm بتنسيق 24 ساعة
class WorkShift {
  final String open;
  final String close;

  const WorkShift({required this.open, required this.close});

  factory WorkShift.fromMap(Map<String, dynamic> map) {
    return WorkShift(
      open: map['open'] ?? '08:00',
      close: map['close'] ?? '22:00',
    );
  }

  Map<String, dynamic> toMap() => {'open': open, 'close': close};

  WorkShift copyWith({String? open, String? close}) {
    return WorkShift(open: open ?? this.open, close: close ?? this.close);
  }
}

// أيام الأسبوع بترتيب العرض (الأحد أولاً) مع المفتاح المخزَّن في Firestore
const List<(String key, String label)> kWeekDays = [
  ('sun', 'الأحد'),
  ('mon', 'الاثنين'),
  ('tue', 'الثلاثاء'),
  ('wed', 'الأربعاء'),
  ('thu', 'الخميس'),
  ('fri', 'الجمعة'),
  ('sat', 'السبت'),
];

// يحوّل DateTime.weekday (الاثنين=1 ... الأحد=7) إلى مفتاح اليوم المخزَّن
String dayKeyForWeekday(int weekday) {
  const map = {1: 'mon', 2: 'tue', 3: 'wed', 4: 'thu', 5: 'fri', 6: 'sat', 7: 'sun'};
  return map[weekday] ?? 'sun';
}
