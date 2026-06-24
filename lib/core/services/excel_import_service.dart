// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:excel/excel.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import 'menu_service.dart';

class ExcelImportService {
  static void downloadTemplate() {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['القائمة'];

    sheet.appendRow([
      TextCellValue('الفئة *'),
      TextCellValue('اسم الصنف *'),
      TextCellValue('الوصف'),
      TextCellValue('السعر *'),
    ]);
    sheet.appendRow([
      TextCellValue('برجر'),
      TextCellValue('برجر زنجر'),
      TextCellValue('دجاج زنجر مقرمش'),
      DoubleCellValue(25.0),
    ]);
    sheet.appendRow([
      TextCellValue('برجر'),
      TextCellValue('برجر لحم'),
      TextCellValue(''),
      DoubleCellValue(30.0),
    ]);
    sheet.appendRow([
      TextCellValue('ساندوتش'),
      TextCellValue('ساندوتش دجاج مشوي'),
      TextCellValue('دجاج مشوي بالتوابل'),
      DoubleCellValue(20.0),
    ]);

    final encoded = excel.encode()!;
    final bytes = Uint8List.fromList(encoded);
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'قالب_القائمة.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<ImportResult> importFromBytes(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.sheets.values.first;

    final existingCats = await MenuService.streamCategories().first;
    final catMap = <String, String>{};
    int catSortOrder = existingCats.length;
    for (final cat in existingCats) {
      catMap[cat.name.trim()] = cat.id;
    }

    int itemsAdded = 0;
    int catsAdded = 0;
    final errors = <String>[];

    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.every((c) => c?.value == null)) continue;

      final catName = row[0]?.value?.toString().trim() ?? '';
      final itemName = row[1]?.value?.toString().trim() ?? '';
      final desc = row[2]?.value?.toString().trim() ?? '';
      final priceRaw = row[3]?.value?.toString().trim() ?? '';

      if (catName.isEmpty || itemName.isEmpty) continue;

      final price = double.tryParse(priceRaw);
      if (price == null) {
        errors.add('صف ${i + 1}: سعر غير صحيح "$priceRaw"');
        continue;
      }

      if (!catMap.containsKey(catName)) {
        final newId = await MenuService.addCategory(CategoryModel(
          id: '',
          name: catName,
          icon: null,
          sortOrder: catSortOrder++,
          isActive: true,
        ));
        catMap[catName] = newId;
        catsAdded++;
      }

      await MenuService.addMenuItem(MenuItemModel(
        id: '',
        name: itemName,
        description: desc,
        categoryId: catMap[catName]!,
        categoryName: catName,
        price: price,
        isAvailable: true,
        sortOrder: i,
      ));
      itemsAdded++;
    }

    return ImportResult(itemsAdded: itemsAdded, catsAdded: catsAdded, errors: errors);
  }
}

class ImportResult {
  final int itemsAdded;
  final int catsAdded;
  final List<String> errors;
  const ImportResult({required this.itemsAdded, required this.catsAdded, required this.errors});
}
