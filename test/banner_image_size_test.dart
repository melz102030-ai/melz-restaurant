import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/services/cloudinary_service.dart';

void main() {
  test('عرض صورة البانر يناسب الشاشة وكثافتها', () {
    expect(CloudinaryService.fullWidthImageSize(360, 2), 800);
    expect(CloudinaryService.fullWidthImageSize(412, 1.75), 800);
    expect(CloudinaryService.fullWidthImageSize(390, 3), 1200);
  });

  test('لا يتجاوز الحد الأعلى ولا ينزل عن الأدنى', () {
    expect(CloudinaryService.fullWidthImageSize(1920, 1), 1200);
    expect(CloudinaryService.fullWidthImageSize(200, 1), 400);
  });
}
