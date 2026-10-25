import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

/// تطبيق جسر صغير مخصَّص لأجهزة Sunmi فقط — لا واجهة فعلية له، وظيفته
/// الوحيدة استقبال رابط بصيغة sunmiprint://print?data=<base64> من تطبيق
/// Meals (نسخة kitchen-lite العاملة في متصفح Chrome)، وتمرير النص المُرسَل
/// مباشرة لطابعة الجهاز الداخلية عبر SDK الرسمي الخاص بـ Sunmi، ثم يغلق
/// نفسه تلقائياً ويعيد المستخدم لتطبيق Meals.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BridgeApp());
}

class BridgeApp extends StatefulWidget {
  const BridgeApp({super.key});

  @override
  State<BridgeApp> createState() => _BridgeAppState();
}

class _BridgeAppState extends State<BridgeApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  String _status = 'جاهز لاستقبال أمر الطباعة...';
  bool _bound = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) await _handle(initial);
    _sub = _appLinks.uriLinkStream.listen(_handle);
  }

  Future<void> _handle(Uri uri) async {
    setState(() => _status = 'جارٍ الطباعة...');
    try {
      final raw = uri.queryParameters['data'];
      if (raw == null || raw.isEmpty) {
        throw 'لا توجد بيانات طباعة في الرابط';
      }
      final text = utf8.decode(base64.decode(Uri.decodeComponent(raw)));
      await _print(text);
      setState(() => _status = 'تمت الطباعة بنجاح');
    } catch (e) {
      setState(() => _status = 'فشلت الطباعة: $e');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) SystemNavigator.pop();
  }

  // السطر الأول يصل دائماً اسم المطعم (راجع buildReceiptPlainText في
  // web_kitchen_lite/app.js) — يُطبع بولد وحجم أكبر ووسط الصفحة، وبقية
  // الإيصال بولد بحجم مقروء ومحاذاة يمين (الاتجاه الطبيعي للنص العربي)
  Future<void> _print(String text) async {
    if (!_bound) {
      await SunmiPrinter.bindingPrinter();
      _bound = true;
    }
    await SunmiPrinter.startTransactionPrint(true);
    var isFirstLine = true;
    for (final line in text.split('\n')) {
      if (line.trim().isEmpty) {
        await SunmiPrinter.lineWrap(1);
        continue;
      }
      if (isFirstLine) {
        await SunmiPrinter.printText(
          line,
          style: SunmiTextStyle(bold: true, fontSize: 38, align: SunmiPrintAlign.CENTER),
        );
        isFirstLine = false;
      } else {
        await SunmiPrinter.printText(
          line,
          style: SunmiTextStyle(bold: true, fontSize: 28, align: SunmiPrintAlign.RIGHT),
        );
      }
    }
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.cutPaper();
    await SunmiPrinter.exitTransactionPrint(true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _status,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
