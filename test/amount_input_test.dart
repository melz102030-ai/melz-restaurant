import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/shared/utils/format_utils.dart';

void main() {
  test('الأرقام العربية والفارسية والفواصل تُقرأ صحيحة', () {
    expect(parseAmount('٣'), 3);
    expect(parseAmount('٢٫٥'), 2.5);
    expect(parseAmount('۱۲'), 12);
    expect(parseAmount('2,5'), 2.5);
    expect(parseAmount('٢،٥'), 2.5);
    expect(parseAmount(' 10 '), 10);
    expect(parseAmount('−٢'), -2);
    expect(parseAmount('-2'), -2);
    expect(parseWholeNumber('٢٠'), 20);
  });

  test('النص غير الرقمي يعطي null لا صفراً', () {
    expect(parseAmount('3 ريال'), isNull);
    expect(parseAmount('ثلاثة'), isNull);
    expect(parseAmount(''), isNull);
    expect(parseWholeNumber('٢٫٥'), isNull);
  });
}
