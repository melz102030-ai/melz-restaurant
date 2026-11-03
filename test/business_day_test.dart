import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/settings_model.dart';
import 'package:melz_restaurant/core/models/work_shift_model.dart';

RestaurantSettings _withShift(String open, String close) => RestaurantSettings(
      workingHours: {
        'mon': [WorkShift(open: open, close: close)],
      },
    );

// وقت الرياض يُكتب هنا صراحة بفارق +3 عن العالمي
DateTime _riyadh(int d, int h, [int m = 0]) =>
    DateTime.utc(2026, 11, d, h, m).subtract(const Duration(hours: 3));

void main() {
  test('فترة تمتد بعد منتصف الليل: اليوم يبدأ عند إغلاقها', () {
    final s = _withShift('16:00', '02:00');
    expect(s.businessDayStartMinutes, 120);
    expect(s.businessDayKeyOf(_riyadh(3, 1)), '2026-11-02', reason: '1 ليلاً تابعة لوردية الأمس');
    expect(s.businessDayKeyOf(_riyadh(3, 2, 30)), '2026-11-03');
    expect(s.businessDayKeyOf(_riyadh(3, 23)), '2026-11-03');
    expect(s.businessDayStartOf(_riyadh(3, 1)), _riyadh(2, 2));
    expect(s.businessDayStartOf(_riyadh(3, 20)), _riyadh(3, 2));
  });

  test('فترة نهارية: اليوم يبدأ من منتصف الليل', () {
    final s = _withShift('08:00', '22:00');
    expect(s.businessDayStartMinutes, 0);
    expect(s.businessDayKeyOf(_riyadh(3, 0, 30)), '2026-11-03');
    expect(s.businessDayStartOf(_riyadh(3, 12)), _riyadh(3, 0));
  });

  test('آخر إغلاق بين الفترات هو بداية اليوم', () {
    const s = RestaurantSettings(
      workingHours: {
        'mon': [WorkShift(open: '16:00', close: '01:00')],
        'fri': [WorkShift(open: '16:00', close: '03:00')],
      },
    );
    expect(s.businessDayStartMinutes, 180);
  });

  test('النمط القديم بفترة يومية واحدة', () {
    const s = RestaurantSettings(openTime: '22:00', closeTime: '02:00');
    expect(s.businessDayStartMinutes, 120);
  });

  test('التاريخ لا يتأثر بمنطقة الجهاز عند نهاية الشهر', () {
    final s = _withShift('08:00', '22:00');
    expect(s.businessDayKeyOf(DateTime.utc(2026, 11, 30, 22)), '2026-12-01');
  });
}
