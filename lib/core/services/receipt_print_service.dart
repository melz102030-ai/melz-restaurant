import 'dart:js' as js;
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/settings_model.dart';

/// طباعة فاتورة/إيصال الطلب تلقائياً على طابعة الجهاز نفسه (الموظف يفتح
/// لوحة التحكم من جهاز متصل بطابعة فواتير — تماماً كأجهزة تطبيقات التوصيل)
/// فور تأكيد الطلب. لا يحتاج أي اتصال بخدمة خارجية أو طابعة شبكية: يعتمد
/// فقط على نافذة طباعة المتصفح القياسية (window.print)، فيعمل مع أي طابعة
/// مُعرَّفة كطابعة افتراضية على نظام الجهاز — بغض النظر عن ماركتها.
class ReceiptPrintService {
  static void printOrder(OrderModel order, RestaurantSettings settings) {
    try {
      final html = _buildReceiptHtml(order, settings);
      js.context.callMethod('printReceipt', [html]);
    } catch (_) {
      // فشل الطباعة لا يجوز أن يوقف أي عملية أساسية (تأكيد الطلب نفسه
      // نجح فعلاً) — يُتجاهل بصمت، الموظف يقدر يطبع يدوياً من زر منفصل لاحقاً
    }
  }

  static String _buildReceiptHtml(OrderModel order, RestaurantSettings settings) {
    final df = DateFormat('dd/MM/yyyy - hh:mm a');
    final shortId = order.id.length > 6 ? order.id.substring(0, 6).toUpperCase() : order.id;

    final itemsRows = order.items.map((item) {
      final optionsLine = item.optionsSummary.isNotEmpty
          ? '<div style="font-size:10px;color:#444;padding-right:14px">${_esc(item.optionsSummary)}</div>'
          : '';
      return '''
        <tr>
          <td style="width:28px;font-weight:bold">×${item.quantity}</td>
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

    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<title>فاتورة</title>
<style>
  @page { margin: 0; }
  * { box-sizing: border-box; }
  body {
    font-family: 'Tahoma', 'Courier New', monospace;
    width: 76mm;
    margin: 0 auto;
    padding: 3mm;
    font-size: 12px;
    color: #000;
  }
  h1 { font-size: 16px; text-align: center; margin: 0 0 2px; }
  .center { text-align: center; }
  .hint { font-size: 10px; color: #555; }
  .line { border-top: 1px dashed #000; margin: 6px 0; }
  table { width: 100%; border-collapse: collapse; font-size: 12px; }
  td { padding: 2px 0; vertical-align: top; }
  .total td { font-weight: bold; font-size: 14px; padding-top: 4px; }
</style>
</head>
<body>
  <h1>${_esc(settings.restaurantName)}</h1>
  <div class="center hint">طلب رقم $shortId</div>
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
    <tr><td>الإجمالي الفرعي</td><td style="text-align:left">${order.subtotal.toStringAsFixed(2)}</td></tr>
    ${order.deliveryFee > 0 ? '<tr><td>التوصيل</td><td style="text-align:left">${order.deliveryFee.toStringAsFixed(2)}</td></tr>' : ''}
    <tr class="total"><td>الإجمالي</td><td style="text-align:left">${order.total.toStringAsFixed(2)}</td></tr>
  </table>
  $notesSection
  <div class="line"></div>
  <div class="center hint">شكراً لطلبك من ${_esc(settings.restaurantName)}</div>
</body>
</html>
''';
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
