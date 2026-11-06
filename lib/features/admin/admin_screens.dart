// شاشات الإدارة في حزمة منفصلة تُحمَّل عند فتحها فقط (راجع app.dart)، حتى لا
// يحمّلها العميل في كل زيارة وهو لا يحتاجها. لا تستوردها مباشرة من شاشات العميل.
export 'screens/admin_shell.dart';
export 'screens/admin_dashboard.dart';
export 'screens/menu_management_screen.dart';
export 'screens/admin_orders_screen.dart';
export 'screens/admin_reports_screen.dart';
export 'screens/admin_settings_screen.dart';
export 'screens/admin_users_screen.dart';
export 'screens/admin_drivers_screen.dart';
export 'screens/admin_delivery_zones_screen.dart';
export 'screens/admin_working_hours_screen.dart';
export 'screens/admin_appearance_screen.dart';
export 'screens/admin_popup_ads_screen.dart';
export 'screens/admin_banners_screen.dart';
export 'screens/admin_splash_screen.dart';
export 'screens/admin_support_screen.dart';
export 'screens/admin_support_ticket_screen.dart';
export 'screens/admin_clear_history_screen.dart';
