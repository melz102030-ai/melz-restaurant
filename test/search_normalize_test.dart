import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/shared/utils/format_utils.dart';

bool _finds(String text, String query) =>
    normalizeForSearch(text).contains(normalizeForSearch(query));

void main() {
  test('اختلافات الكتابة العربية لا تمنع إيجاد الصنف', () {
    expect(_finds('برجر جبنة', 'جبنه'), isTrue);
    expect(_finds('طبق أحمد', 'احمد'), isTrue);
    expect(_finds('إدام', 'ادام'), isTrue);
    expect(_finds('شاورما بالمايونيز', 'مايونيز'), isTrue);
    expect(_finds('فتّة', 'فته'), isTrue);
    expect(_finds('حلوى', 'حلوي'), isTrue);
  });

  test('لا يوسّع البحث إلى ما لا يطابق، ويتجاهل حالة الأحرف والمسافات الزائدة', () {
    expect(_finds('برجر جبنة', 'دجاج'), isFalse);
    expect(_finds('Zinger Burger', '  zinger  burger '), isTrue);
  });
}
