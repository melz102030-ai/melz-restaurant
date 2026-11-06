import 'dart:convert';
import 'dart:js' as js;
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/settings_model.dart';

/// طباعة فاتورة/إيصال الطلب تلقائياً على طابعة الجهاز نفسه (الموظف يفتح
/// لوحة التحكم من جهاز متصل بطابعة فواتير — تماماً كأجهزة تطبيقات التوصيل)
/// فور تأكيد الطلب. على الأجهزة العادية يعتمد على نافذة طباعة المتصفح
/// القياسية (window.print). أما على نسخة kitchen-lite (أجهزة Sunmi ذات
/// طابعة داخلية غير مرئية لنظام الطباعة القياسي) فتُرسَل نسخة نصية بسيطة
/// عبر رابط sunmiprint:// لتطبيق جسر مرافق مثبَّت على الجهاز (راجع
/// sunmi_print_bridge/) يطبعها مباشرة عبر SDK الرسمي الخاص بـ Sunmi.
class ReceiptPrintService {
  static void printOrder(OrderModel order, RestaurantSettings settings) {
    try {
      final html = _buildReceiptHtml(order, settings);
      final plainText = _buildReceiptPlainText(order, settings);
      js.context.callMethod('printReceipt', [html, plainText]);
    } catch (_) {
      // فشل الطباعة لا يجوز أن يوقف أي عملية أساسية (تأكيد الطلب نفسه
      // نجح فعلاً) — يُتجاهل بصمت، الموظف يقدر يطبع يدوياً من زر منفصل لاحقاً
    }
  }

  /// نسخة نصية بسيطة (بلا HTML) بعرض 32 حرفاً تقريباً — مناسبة لطابعات
  /// حرارية صغيرة (48 ملم) تُطبع عبر SDK مباشر بدل محرك عرض متصفح
  static String _buildReceiptPlainText(OrderModel order, RestaurantSettings settings) {
    final df = DateFormat('dd/MM/yyyy - hh:mm a');
    const sep = '--------------------------------';
    final b = StringBuffer();
    b.writeln(settings.restaurantName);
    b.writeln('طلب رقم ${order.orderNumberLabel}');
    b.writeln(df.format(order.createdAt));
    b.writeln(sep);
    b.writeln('العميل: ${order.customerName}');
    b.writeln('الجوال: ${order.customerPhone}');
    b.writeln('النوع: ${order.orderType == OrderType.delivery ? 'توصيل' : 'استلام من المطعم'}');
    if (order.orderType == OrderType.delivery && order.deliveryAddress != null) {
      b.writeln('العنوان: ${order.deliveryAddress}');
    }
    b.writeln(sep);
    for (final item in order.items) {
      // خط نحيف بين الأصناف، حتى يتضح أين تنتهي خيارات كل صنف
      if (item != order.items.first) b.writeln('____________________');
      b.writeln('×${item.shownQuantity}  ${item.name}  ${item.total.toStringAsFixed(2)}');
      for (final line in _optionsReceiptLines(item)) {
        b.writeln('   $line');
      }
    }
    b.writeln(sep);
    if (order.deliveryFee > 0) {
      b.writeln('التوصيل: ${order.deliveryFee.toStringAsFixed(2)}');
    }
    b.writeln('الإجمالي: ${order.total.toStringAsFixed(2)}');
    if (order.notes != null && order.notes!.isNotEmpty) {
      b.writeln(sep);
      b.writeln('ملاحظات: ${order.notes}');
    }
    b.writeln(sep);
    b.writeln('شكراً لطلبك من ${settings.restaurantName}');
    return base64.encode(utf8.encode(b.toString()));
  }

  static String _buildReceiptHtml(OrderModel order, RestaurantSettings settings) {
    final df = DateFormat('dd/MM/yyyy - hh:mm a');

    final itemsRows = order.items.indexed.map((entry) {
      final (index, item) = entry;
      final optionsLine = _optionsReceiptLines(item)
          .map((line) =>
              '<div style="font-size:15px;font-weight:bold;color:#000;padding-right:14px">${_esc(line)}</div>')
          .join();
      // خط نحيف بين الأصناف، حتى يتضح أين تنتهي خيارات كل صنف
      return '''
        <tr${index > 0 ? ' style="border-top:1px solid #000"' : ''}>
          <td style="width:28px;font-weight:bold">×${item.shownQuantity}</td>
          <td>${_esc(item.name)}$optionsLine</td>
          <td style="text-align:left;white-space:nowrap">${item.total.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join();

    final addressLine = order.orderType == OrderType.delivery && order.deliveryAddress != null
        ? '<div>العنوان: ${_esc(order.deliveryAddress!)}</div>'
        : '';

    final notesSection = order.notes != null && order.notes!.isNotEmpty
        ? '<div class="line"></div><div>ملاحظات: ${_esc(order.notes!)}</div>'
        : '';

    // قطعة محتوى فقط (بلا html/head/body) — تُحقَن داخل عنصر ثابت في
    // web/index.html (#receipt-print-area) يُظهره @media print وحده عند
    // الطباعة الفعلية، بدل مستند كامل داخل iframe (أقل توافقاً على أندرويد)
    return '''
<style>
  #receipt-print-area { font-family: 'Tahoma', 'Courier New', monospace; color: #000; }
  #receipt-print-area .slip { width: 76mm; margin: 0 auto; padding: 3mm; font-size: 17px; font-weight: bold; }
  #receipt-print-area h1 { font-size: 22px; font-weight: bold; text-align: center; margin: 0 0 3px; }
  #receipt-print-area .center { text-align: center; }
  #receipt-print-area .hint { font-size: 15px; font-weight: bold; color: #000; }
  #receipt-print-area .line { border-top: 2px dashed #000; margin: 8px 0; }
  #receipt-print-area table { width: 100%; border-collapse: collapse; font-size: 17px; font-weight: bold; }
  #receipt-print-area td { padding: 3px 0; vertical-align: top; }
  #receipt-print-area .total td { font-weight: bold; font-size: 20px; padding-top: 5px; }
</style>
<div class="slip">
  <h1>${_esc(settings.restaurantName)}</h1>
  <div class="center hint">طلب رقم ${order.orderNumberLabel}</div>
  <div class="center hint">${df.format(order.createdAt)}</div>
  <div class="line"></div>
  <div>العميل: ${_esc(order.customerName)}</div>
  <div>الجوال: ${_esc(order.customerPhone)}</div>
  <div>النوع: ${order.orderType == OrderType.delivery ? 'توصيل' : 'استلام من المطعم'}</div>
  $addressLine
  <div class="line"></div>
  <table>$itemsRows</table>
  <div class="line"></div>
  <table>
    ${order.deliveryFee > 0 ? '<tr><td>التوصيل</td><td style="text-align:left">${order.deliveryFee.toStringAsFixed(2)}</td></tr>' : ''}
    <tr class="total"><td>الإجمالي</td><td style="text-align:left">${order.total.toStringAsFixed(2)}</td></tr>
  </table>
  $notesSection
  <div class="line"></div>
  <div class="center hint">شكراً لطلبك من ${_esc(settings.restaurantName)}</div>
</div>
''';
  }

  // كل خيار في سطر مستقل تحت صنفه، بلا عناوين المجموعات (الإضافات، الخيارات...)،
  // والوجبة سطر واحد "اسمها (اختياره)"، والمدفوع بجواره سعره "+5"
  static List<String> _optionsReceiptLines(OrderItem item) => [
        for (final o in item.selectedOptions)
          if (o.isMeal)
            '- ${o.mealLine}${_priceTag(o.extra)}'
          else
            for (var i = 0; i < o.selectedNames.length; i++)
              '- ${o.selectedNames[i]}${_priceTag(o.extraOf(i))}',
      ];

  static String _priceTag(double n) {
    if (n <= 0) return '';
    return ' +${n == n.roundToDouble() ? n.toInt() : n.toStringAsFixed(2)}';
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
