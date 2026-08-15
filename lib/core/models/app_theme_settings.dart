enum MenuDisplayStyle { list, grid, horizontal }

enum CardStyle { rounded, sharp }

class AppThemeSettings {
  final int primaryColor;
  final int secondaryColor;
  final int backgroundColor;
  final int cardColor;
  final int textColor;
  // لون مربعات الكتابة (TextField) في كل التطبيق — كانت سابقاً بلا لون خاص
  // بها، تُشتق تلقائياً بتظليل خفيف جداً (6%) من لون الخلفية فتبدو رمادية
  // باهتة بلا هوية بصرية واضحة؛ الآن قابلة للتخصيص المباشر مثل بقية الألوان
  final int inputFieldColor;
  final String fontFamily;
  final CardStyle cardStyle;
  final MenuDisplayStyle menuDisplayStyle;

  const AppThemeSettings({
    this.primaryColor = 0xFF6A0DAD, // بنفسجي (الافتراضي)
    this.secondaryColor = 0xFF800040, // منجاوي (الافتراضي)
    this.backgroundColor = 0xFFF5EEDC, // بيج (الافتراضي)
    this.cardColor = 0xFFFFFFFF,
    this.textColor = 0xFF1A0030,
    this.inputFieldColor = 0xFFEADFC8, // نفس الظل المشتق سابقاً — لا تغيير بصري حتى يخصّصه الأدمن
    this.fontFamily = 'Cairo',
    this.cardStyle = CardStyle.rounded,
    this.menuDisplayStyle = MenuDisplayStyle.list,
  });

  // خطوط عربية مختارة تدعم Google Fonts
  static const List<String> availableFonts = [
    'Cairo',
    'Tajawal',
    'Almarai',
    'Changa',
    'ElMessiri',
    'Markazi Text',
    'Reem Kufi',
    'IBM Plex Sans Arabic',
  ];

  factory AppThemeSettings.fromMap(Map<String, dynamic> map) {
    return AppThemeSettings(
      primaryColor: map['primaryColor'] ?? 0xFF6A0DAD,
      secondaryColor: map['secondaryColor'] ?? 0xFF800040,
      backgroundColor: map['backgroundColor'] ?? 0xFFF5EEDC,
      cardColor: map['cardColor'] ?? 0xFFFFFFFF,
      textColor: map['textColor'] ?? 0xFF1A0030,
      inputFieldColor: map['inputFieldColor'] ?? 0xFFEADFC8,
      fontFamily: map['fontFamily'] ?? 'Cairo',
      cardStyle: CardStyle.values.firstWhere(
        (s) => s.name == (map['cardStyle'] ?? 'rounded'),
        orElse: () => CardStyle.rounded,
      ),
      menuDisplayStyle: MenuDisplayStyle.values.firstWhere(
        (s) => s.name == (map['menuDisplayStyle'] ?? 'list'),
        orElse: () => MenuDisplayStyle.list,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'cardColor': cardColor,
      'textColor': textColor,
      'inputFieldColor': inputFieldColor,
      'fontFamily': fontFamily,
      'cardStyle': cardStyle.name,
      'menuDisplayStyle': menuDisplayStyle.name,
    };
  }

  AppThemeSettings copyWith({
    int? primaryColor,
    int? secondaryColor,
    int? backgroundColor,
    int? cardColor,
    int? textColor,
    int? inputFieldColor,
    String? fontFamily,
    CardStyle? cardStyle,
    MenuDisplayStyle? menuDisplayStyle,
  }) {
    return AppThemeSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      textColor: textColor ?? this.textColor,
      inputFieldColor: inputFieldColor ?? this.inputFieldColor,
      fontFamily: fontFamily ?? this.fontFamily,
      cardStyle: cardStyle ?? this.cardStyle,
      menuDisplayStyle: menuDisplayStyle ?? this.menuDisplayStyle,
    );
  }
}
