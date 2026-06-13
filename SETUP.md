# مطعم ميلز - دليل الإعداد

## هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── app.dart                     # التوجيه والتطبيق الرئيسي
├── firebase_options.dart        # إعدادات Firebase (يجب تعبئتها)
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # ألوان المطعم (بنفسجي، منجاوي، أحمر)
│   │   └── app_strings.dart     # النصوص العربية
│   ├── theme/
│   │   └── app_theme.dart       # ثيم التطبيق الداكن
│   ├── models/
│   │   ├── user_model.dart      # نموذج المستخدم (عميل/إدارة/مطبخ)
│   │   ├── menu_item_model.dart # نموذج عنصر القائمة
│   │   ├── category_model.dart  # نموذج الفئة
│   │   ├── order_model.dart     # نموذج الطلب
│   │   └── settings_model.dart  # إعدادات المطعم
│   ├── services/
│   │   ├── auth_service.dart    # خدمة المصادقة + OTP واتساب
│   │   ├── menu_service.dart    # خدمة القائمة (CRUD)
│   │   ├── order_service.dart   # خدمة الطلبات
│   │   ├── cloudinary_service.dart # رفع الصور
│   │   └── settings_service.dart   # إعدادات المطعم
│   └── providers/
│       ├── auth_provider.dart   # حالة المصادقة
│       ├── cart_provider.dart   # سلة التسوق
│       └── settings_provider.dart
├── features/
│   ├── auth/screens/
│   │   ├── login_screen.dart    # تسجيل دخول العميل (جوال)
│   │   ├── otp_screen.dart      # التحقق عبر واتساب
│   │   └── staff_login_screen.dart # دخول الإدارة/المطبخ
│   ├── customer/
│   │   ├── screens/
│   │   │   ├── customer_home_screen.dart   # الرئيسية + قائمة الطعام
│   │   │   ├── cart_screen.dart            # سلة التسوق
│   │   │   ├── order_tracking_screen.dart  # تتبع الطلب
│   │   │   └── profile_screen.dart         # الملف الشخصي
│   │   └── widgets/
│   │       └── menu_item_card.dart
│   ├── admin/screens/
│   │   ├── admin_shell.dart           # الشريط الجانبي للإدارة
│   │   ├── admin_dashboard.dart       # لوحة التحكم + إحصائيات
│   │   ├── menu_management_screen.dart # إدارة القائمة والفئات
│   │   ├── admin_orders_screen.dart   # إدارة الطلبات
│   │   ├── admin_reports_screen.dart  # التقارير والرسوم البيانية
│   │   ├── admin_settings_screen.dart # إعدادات المطعم
│   │   └── admin_users_screen.dart    # إدارة المستخدمين
│   └── kitchen/screens/
│       └── kitchen_screen.dart        # شاشة المطبخ
└── shared/widgets/
    ├── app_button.dart
    ├── loading_widget.dart
    └── gradient_container.dart
```

---

## خطوات الإعداد

### 1. إنشاء مشروع Firebase

1. اذهب إلى [console.firebase.google.com](https://console.firebase.google.com)
2. أنشئ مشروعاً جديداً (مثال: `melz-restaurant`)
3. فعّل **Firestore Database** (ابدأ في وضع الاختبار)
4. فعّل **Firebase Storage**
5. أضف **Web App** وانسخ إعدادات الاتصال

### 2. تعبئة firebase_options.dart

افتح `lib/firebase_options.dart` وعبّئ القيم:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_KEY',           // من Firebase Console
  appId: '1:xxx:web:xxx',
  messagingSenderId: '123456789',
  projectId: 'melz-restaurant',
  authDomain: 'melz-restaurant.firebaseapp.com',
  storageBucket: 'melz-restaurant.appspot.com',
);
```

### 3. قواعد Firestore (Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // إعدادات المطعم - يقرأها الجميع، يعدلها الإدارة فقط
    match /settings/{doc} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // الفئات والقائمة - يقرأها الجميع
    match /categories/{doc} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /menu_items/{doc} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // الطلبات
    match /orders/{doc} {
      allow read, write: if true; // للتطوير - عدّل في الإنتاج
    }
    
    // المستخدمون
    match /users/{doc} {
      allow read, write: if true;
    }
    
    // رموز OTP
    match /otp_codes/{doc} {
      allow read, write: if true;
    }
  }
}
```

### 4. إعداد Cloudinary

1. أنشئ حساباً في [cloudinary.com](https://cloudinary.com)
2. أنشئ **unsigned upload preset**
3. عدّل `lib/core/services/cloudinary_service.dart`:

```dart
static const String cloudName = 'YOUR_CLOUD_NAME';
static const String uploadPreset = 'YOUR_PRESET';
```

### 5. إعداد واتساب (للبيئة الإنتاجية)

في `lib/core/services/auth_service.dart`، عدّل `sendOtp()` لاستخدام:
- **Twilio WhatsApp API**: أو
- **WhatsApp Business Cloud API** من Meta

حالياً، رمز OTP يظهر في بطاقة التطوير (dev mode).

---

## تشغيل التطبيق

```bash
# تشغيل محلياً
flutter run -d chrome

# بناء للنشر
flutter build web

# النشر على Firebase Hosting
firebase deploy --only hosting
```

---

## حسابات الوصول

| الدور | طريقة الدخول |
|-------|-------------|
| **عميل** | رقم الجوال + OTP واتساب |
| **إدارة** | /staff-login → رقم جوال + كلمة مرور |
| **مطبخ** | /staff-login → رقم جوال + كلمة مرور |

### إضافة أول مدير

في Firestore، أضف وثيقة في `users`:
```json
{
  "phone": "+966XXXXXXXXX",
  "name": "مدير النظام",
  "role": "admin",
  "staffPassword": "your_password",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

## ميزات التطبيق

### واجهة العميل
- ✅ تسجيل الدخول بالجوال + OTP واتساب
- ✅ تصفح قائمة الطعام بالفئات
- ✅ البحث في القائمة
- ✅ إضافة/إزالة من السلة
- ✅ إتمام الطلب مع ملاحظات
- ✅ تتبع الطلب لحظة بلحظة (real-time)
- ✅ سجل الطلبات السابقة
- ✅ تعديل الاسم في الملف الشخصي

### واجهة الإدارة
- ✅ لوحة تحكم مع إحصائيات
- ✅ رسوم بيانية للإيرادات (7 أيام)
- ✅ إدارة القائمة (إضافة/تعديل/حذف)
- ✅ إدارة الفئات مع إيموجي
- ✅ رفع صور المنتجات عبر Cloudinary
- ✅ تطبيق خصومات على الأصناف
- ✅ إدارة الطلبات (تصفية حسب الحالة)
- ✅ تقارير وتحليلات متقدمة
- ✅ إدارة المستخدمين وتغيير الصلاحيات
- ✅ إعدادات كاملة (ساعات عمل، أسعار، واتساب...)
- ✅ تبديل وضع الفتح/الإغلاق

### واجهة المطبخ
- ✅ عرض الطلبات الجديدة مع تنبيه عاجل
- ✅ تحديث حالة الطلب (تأكيد → تحضير → جاهز → تسليم)
- ✅ إرسال ملاحظات ووقت متوقع للعميل
- ✅ تقسيم الطلبات: جديد / قيد التنفيذ / جاهز
- ✅ عرض شبكي للشاشات الكبيرة
