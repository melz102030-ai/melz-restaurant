import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/shared/utils/format_utils.dart';

void main() {
  test('يكمل الرابط المكتوب بدون https', () {
    expect(normalizeWebUrl(' example.com '), 'https://example.com');
    expect(normalizeWebUrl('www.example.com/offer?a=1'), 'https://www.example.com/offer?a=1');
    expect(normalizeWebUrl('https://example.com/x'), 'https://example.com/x');
    expect(normalizeWebUrl('http://example.com'), 'http://example.com');
  });

  test('يرفض ما ليس رابط موقع', () {
    for (final bad in [
      '',
      '   ',
      'عرض خاص',
      'example',
      'javascript:alert(1)',
      'mailto:a@example.com',
      'ftp://example.com',
      'https://user@example.com',
    ]) {
      expect(normalizeWebUrl(bad), isNull, reason: bad);
    }
  });
}
