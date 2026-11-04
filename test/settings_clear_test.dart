import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/settings_model.dart';

void main() {
  const full = RestaurantSettings(
    googleReviewUrl: 'https://g.page/r',
    address: 'الرياض',
    welcomeMessage: 'أهلاً',
    bankIban: 'SA00',
    bankAccountHolderName: 'المطعم',
    bankName: 'البنك',
    supportWhatsappNumber: '0500000000',
  );

  test('الحقل الفارغ يمسح القيمة، ويصل المسح إلى ما يُحفظ', () {
    final cleared = full.copyWith(
      googleReviewUrl: '',
      address: '',
      welcomeMessage: ' ',
      bankIban: '',
      bankAccountHolderName: '',
      bankName: '',
      supportWhatsappNumber: '',
    );

    final map = cleared.toMap();
    for (final key in [
      'googleReviewUrl',
      'address',
      'welcomeMessage',
      'bankIban',
      'bankAccountHolderName',
      'bankName',
      'supportWhatsappNumber',
    ]) {
      // يجب أن يبقى المفتاح بقيمة null: الحفظ يدمج، فغيابه يعني بقاء القيمة القديمة
      expect(map.containsKey(key), isTrue, reason: key);
      expect(map[key], isNull, reason: key);
    }
    expect(cleared.hasBankTransferInfo, isFalse);
  });

  test('عدم تمرير الحقل من شاشة أخرى يبقي قيمته', () {
    final other = full.copyWith(isOpen: false);

    expect(other.bankIban, 'SA00');
    expect(other.address, 'الرياض');
    expect(other.supportWhatsappNumber, '0500000000');
  });

  test('القيمة الجديدة تستبدل القديمة', () {
    expect(full.copyWith(bankIban: 'SA99').bankIban, 'SA99');
  });
}
