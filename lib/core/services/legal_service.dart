import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/legal_document_model.dart';

abstract class LegalService {
  static const _col = 'legal';
  static const privacyId = 'privacy_policy';
  static const termsId = 'terms_conditions';

  static CollectionReference get _ref =>
      FirebaseFirestore.instance.collection(_col);

  static Future<LegalDocumentModel?> getDocument(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return LegalDocumentModel.fromFirestore(doc);
  }

  static Stream<LegalDocumentModel?> streamDocument(String id) {
    return _ref.doc(id).snapshots().map(
          (doc) => doc.exists ? LegalDocumentModel.fromFirestore(doc) : null,
        );
  }

  static Future<void> saveDocument(LegalDocumentModel doc) =>
      _ref.doc(doc.id).set(doc.toMap());

  static Future<void> seedIfMissing() async {
    await Future.wait([
      _seedDoc(privacyId, _defaultPrivacy),
      _seedDoc(termsId, _defaultTerms),
    ]);
  }

  static Future<void> _seedDoc(String id, LegalDocumentModel doc) async {
    final existing = await _ref.doc(id).get();
    if (!existing.exists) await _ref.doc(id).set(doc.toMap());
  }

  // ─── المحتوى الافتراضي الأولي ─────────────────────────────────────────────

  static final _defaultPrivacy = LegalDocumentModel(
    id: privacyId,
    title: 'سياسة الخصوصية',
    sections: [
      LegalSection(heading: 'المقدمة', body: 'تلتزم ميلز بحماية خصوصيتك وفق نظام حماية البيانات الشخصية في المملكة العربية السعودية (PDPL). توضّح هذه السياسة كيفية جمع بياناتك الشخصية واستخدامها وحمايتها عند استخدام موقعنا.'),
      LegalSection(heading: 'المعلومات التي نجمعها', body: 'رقم الجوال: للتحقق من هويتك والتواصل معك بشأن طلبك.\nسجل الطلبات: لعرض طلباتك السابقة وتسهيل إعادتها.\nبيانات الجهاز: نوع المتصفح ونظام التشغيل لتحسين أداء الموقع.'),
      LegalSection(heading: 'كيف نستخدم بياناتك', body: 'معالجة طلباتك وتأكيدها وإبلاغك بحالتها.\nالتواصل معك عند الحاجة بشأن طلبك.\nتحسين تجربة الاستخدام وجودة خدمتنا.\nالامتثال للمتطلبات القانونية والتنظيمية.'),
      LegalSection(heading: 'مشاركة البيانات', body: 'لا نبيع بياناتك الشخصية ولا نشاركها مع أطراف خارجية إلا في الحالات التالية:\n\n• مزود خدمة الدفع لإتمام معاملات مدى وApple Pay بأمان.\n• مزود خدمة رسائل التحقق (OTP) لإثبات ملكية رقم الجوال.\n• الجهات الحكومية حين يقتضي ذلك القانون السعودي.'),
      LegalSection(heading: 'حفظ البيانات وأمانها', body: 'نحتفظ ببياناتك طالما حسابك نشط أو لما تقتضيه المتطلبات القانونية.\nتُطبَّق تدابير تقنية لحماية بياناتك من الوصول غير المصرّح به.\nتتم معالجة بيانات الدفع عبر بوابات معتمدة بمعايير PCI DSS.'),
      LegalSection(heading: 'حقوقك وفق نظام PDPL', body: 'يحق لك في أي وقت:\n\n• الاطلاع على بياناتك الشخصية المحفوظة لدينا.\n• طلب تصحيح أي بيانات غير دقيقة.\n• طلب حذف بياناتك مع مراعاة المتطلبات القانونية.\n• الاعتراض على معالجة بياناتك في حالات معينة.'),
      LegalSection(heading: 'ملفات الجلسة', body: 'يستخدم الموقع ملفات جلسة ضرورية للتشغيل فقط، ولا يستخدم أي ملفات تتبع لأغراض إعلانية.'),
      LegalSection(heading: 'التواصل والدعم', body: 'لممارسة أي من حقوقك أو للاستفسار عن خصوصيتك، تواصل معنا مباشرة عبر قسم الدعم في موقع ميلز.'),
      LegalSection(heading: 'التحديثات', body: 'قد نُحدّث هذه السياسة من وقت لآخر وفق متطلبات الأنظمة. سنُبلّغك بأي تغييرات جوهرية عبر الموقع.'),
    ],
  );

  static final _defaultTerms = LegalDocumentModel(
    id: termsId,
    title: 'الشروط والأحكام',
    sections: [
      LegalSection(heading: 'المقدمة', body: 'مرحباً بك في موقع ميلز لطلب الوجبات في جدة. باستخدامك للموقع، فإنك تقرّ بقراءة هذه الشروط والموافقة عليها. إن كنت لا توافق على أي منها، يرجى عدم استخدام الموقع.'),
      LegalSection(heading: 'الحساب والبيانات', body: 'أنت مسؤول عن صحة رقم جوالك المُدخَل وعن الحفاظ على خصوصيته.\nفي حال الاشتباه بأي استخدام غير مصرّح به لبياناتك، يرجى التواصل معنا فوراً عبر الدعم.\nنحتفظ بحق تعليق أي حساب يُستخدم بصورة مخالفة لهذه الشروط.'),
      LegalSection(heading: 'الطلبات', body: 'تُعدّ الطلبات مؤكدة بعد إتمام الدفع واستلام رسالة التأكيد.\nأوقات التحضير المعروضة تقديرية وقد تتغير وفق ضغط العمل.\nنحتفظ بالحق في رفض أي طلب لأسباب تشغيلية مع استرجاع المبلغ كاملاً.\nخدمة ميلز تعمل على نظام الاستلام من المطعم فقط.'),
      LegalSection(heading: 'الأسعار والدفع', body: 'جميع الأسعار بالريال السعودي وتشمل ضريبة القيمة المضافة.\nنقبل الدفع عبر مدى وApple Pay فقط.\nلا تُخزَّن بيانات بطاقتك على خوادمنا — تتم معالجتها عبر بوابة دفع معتمدة.\nالأسعار قابلة للتغيير في أي وقت وتُطبَّق على الطلبات الجديدة فقط.'),
      LegalSection(heading: 'الإلغاء والاسترجاع', body: 'يمكن إلغاء الطلب قبل بدء التحضير من خلال التواصل معنا عبر الدعم.\nالطلبات التي بدأ تحضيرها لا يمكن إلغاؤها.\nفي حال وجود خلل في الطلب أو خطأ من جانبنا، يُسترجع المبلغ المقابل للجزء المتأثر فقط.\nيُعالج الاسترجاع خلال 5-7 أيام عمل بحسب طريقة الدفع المستخدمة.'),
      LegalSection(heading: 'سلوك المستخدم', body: 'تلتزم بعدم استخدام الموقع لأغراض غير مشروعة أو بأي طريقة تضرّ بالموقع أو مستخدميه أو سمعة ميلز.'),
      LegalSection(heading: 'الملكية الفكرية', body: 'جميع محتويات الموقع من نصوص وصور وشعارات هي ملك حصري لميلز ومحمية بموجب قوانين الملكية الفكرية في المملكة العربية السعودية.'),
      LegalSection(heading: 'تحديد المسؤولية', body: 'لا يتحمل الموقع مسؤولية أي تأخير ناجم عن ظروف خارجة عن إرادتنا. مسؤوليتنا القصوى تقتصر على قيمة الجزء المتأثر من الطلب.'),
      LegalSection(heading: 'القانون المُطبَّق', body: 'تخضع هذه الشروط لأنظمة المملكة العربية السعودية، وأي نزاع يُرفع أمام الجهات القضائية المختصة في جدة.'),
      LegalSection(heading: 'التعديلات', body: 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. الاستمرار في استخدام الموقع بعد نشر التعديلات يُعدّ قبولاً لها.'),
    ],
  );
}
