import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import '../../../core/constants/app_colors.dart';
import '../../../core/models/delivery_zone_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/delivery_location_cache_provider.dart';
import '../../../core/providers/delivery_zone_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';

class _SearchResult {
  final String displayName;
  final double lat;
  final double lon;
  const _SearchResult({required this.displayName, required this.lat, required this.lon});
}

class DeliveryLocationResult {
  final double lat;
  final double lng;
  final String? addressNote;
  const DeliveryLocationResult({
    required this.lat,
    required this.lng,
    this.addressNote,
  });
}

// اختيار موقع التوصيل عبر تحديد الموقع الحالي (GPS) أو تحريك الخريطة يدوياً
class DeliveryLocationPickerScreen extends ConsumerStatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialNote;

  const DeliveryLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialNote,
  });

  @override
  ConsumerState<DeliveryLocationPickerScreen> createState() =>
      _DeliveryLocationPickerScreenState();
}

class _DeliveryLocationPickerScreenState
    extends ConsumerState<DeliveryLocationPickerScreen> {
  final _mapController = MapController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  // الرياض كموقع افتراضي عند عدم توفر GPS أو موقع سابق
  ll.LatLng _center = const ll.LatLng(24.7136, 46.6753);
  bool _locating = false;
  bool _hasPicked = false;
  bool _searching = false;
  List<_SearchResult> _searchResults = [];
  Timer? _geocodeDebounce;
  String? _detectedAddress;
  bool _reverseGeocoding = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl.text = widget.initialNote ?? '';
    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = ll.LatLng(widget.initialLat!, widget.initialLng!);
      _hasPicked = true;
      _scheduleReverseGeocode(_center);
    } else {
      // موقع اكتُشف مسبقاً عند اختيار "توصيل" من الشاشة الرئيسية — يُستخدم فوراً
      // بدل تكرار طلب الإذن والانتظار على GPS من جديد
      final cached = ref.read(cachedDeliveryLocationProvider);
      if (cached != null) {
        _center = ll.LatLng(cached.lat, cached.lng);
        _hasPicked = true;
        _scheduleReverseGeocode(_center);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation());
      }
    }
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ترجمة الإحداثيات إلى عنوان مقروء (اسم الحي/الشارع) — بعد توقف قصير عن
  // تحريك الخريطة، لتفادي إغراق خدمة Nominatim بطلب لكل بكسل تحريك
  void _scheduleReverseGeocode(ll.LatLng point) {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 700), () => _reverseGeocode(point));
  }

  Future<void> _reverseGeocode(ll.LatLng point) async {
    if (!mounted) return;
    setState(() => _reverseGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}'
        '&format=json&accept-language=ar&zoom=18',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'melz-restaurant-app'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('status ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final addr = data['address'] as Map<String, dynamic>?;
      String? address;
      if (addr != null) {
        final parts = [
          addr['neighbourhood'] ?? addr['suburb'] ?? addr['quarter'],
          addr['road'],
          addr['city'] ?? addr['town'] ?? addr['county'],
        ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
        address = parts.isNotEmpty ? parts.join('، ') : data['display_name'] as String?;
      } else {
        address = data['display_name'] as String?;
      }
      if (!mounted) return;
      setState(() => _detectedAddress = address);
    } catch (_) {
      // تجاهل بصمت — العنوان النصي تحسين إضافي وليس شرطاً لتأكيد الموقع
    } finally {
      if (mounted) setState(() => _reverseGeocoding = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searchResults = [];
    });
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(query.trim())}'
        '&format=json&limit=6&accept-language=ar',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'melz-restaurant-app'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('status ${response.statusCode}');
      final data = jsonDecode(response.body) as List;
      final results = data
          .map((r) => _SearchResult(
                displayName: r['display_name'] as String,
                lat: double.parse(r['lat'] as String),
                lon: double.parse(r['lon'] as String),
              ))
          .toList();
      if (!mounted) return;
      setState(() => _searchResults = results);
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('لم يتم العثور على نتائج لهذا البحث'),
          backgroundColor: AppColors.warning,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذّر البحث، تحقق من اتصال الإنترنت'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectSearchResult(_SearchResult r) {
    final target = ll.LatLng(r.lat, r.lon);
    setState(() {
      _center = target;
      _hasPicked = true;
      _searchResults = [];
      _searchCtrl.text = r.displayName;
    });
    _mapController.move(target, 16);
    _scheduleReverseGeocode(target);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم رفض إذن الموقع — يمكنك تحديد موقعك يدوياً بتحريك الخريطة'),
            backgroundColor: AppColors.warning,
          ));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = ll.LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _center = target;
        _hasPicked = true;
      });
      _mapController.move(target, 16);
      _scheduleReverseGeocode(target);
      ref.read(cachedDeliveryLocationProvider.notifier).state =
          CachedLatLng(pos.latitude, pos.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تعذّر تحديد موقعك، حدّده يدوياً على الخريطة'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    final extra = _noteCtrl.text.trim();
    final combinedAddress = [
      if (_detectedAddress != null && _detectedAddress!.trim().isNotEmpty) _detectedAddress!.trim(),
      if (extra.isNotEmpty) extra,
    ].join(' — ');

    // يُحفظ كموقع افتراضي للعميل تلقائياً — يُستخدم في طلباته القادمة حتى يغيّره.
    // يُنتظر هنا كي لا يُفقد الخطأ بصمت، لكن فشل الحفظ لا يمنع تأكيد الموقع
    // الحالي للطلب الجاري — العميل لا يحتاج معرفة تفاصيل هذا الحفظ الخلفي
    final user = ref.read(authProvider);
    if (user != null) {
      try {
        await AuthService.updateSavedLocation(
          user.id,
          lat: _center.latitude,
          lng: _center.longitude,
          address: combinedAddress.isEmpty ? null : combinedAddress,
        );
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      DeliveryLocationResult(
        lat: _center.latitude,
        lng: _center.longitude,
        addressNote: combinedAddress.isEmpty ? null : combinedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final zones = ref.watch(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];
    final showServiceArea =
        settings.useDeliveryZones && settings.hasRestaurantLocation && zones.isNotEmpty;
    final maxRadiusKm =
        showServiceArea ? zones.map((z) => z.maxDistanceKm).reduce((a, b) => a > b ? a : b) : null;

    double? distanceFromRestaurantKm;
    if (showServiceArea) {
      distanceFromRestaurantKm = Geolocator.distanceBetween(
            settings.restaurantLat!,
            settings.restaurantLng!,
            _center.latitude,
            _center.longitude,
          ) /
          1000;
    }
    final isOutsideArea =
        maxRadiusKm != null && (distanceFromRestaurantKm ?? 0) > maxRadiusKm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد موقع التوصيل'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15,
                    onPositionChanged: (position, hasGesture) {
                      final center = position.center;
                      if (hasGesture && center != null) {
                        setState(() {
                          _center = center;
                          _hasPicked = true;
                        });
                        _scheduleReverseGeocode(center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.melz.restaurant',
                    ),
                    // دائرة شفافة توضّح النطاق الكامل الذي يوصّل له المطعم
                    if (showServiceArea)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: ll.LatLng(settings.restaurantLat!, settings.restaurantLng!),
                            radius: maxRadiusKm! * 1000,
                            useRadiusInMeter: true,
                            color: AppColors.purple.withOpacity(0.08),
                            borderColor: AppColors.purple.withOpacity(0.6),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                  ],
                ),
                // دبوس ثابت في منتصف الشاشة — الموقع المختار هو مركز الخريطة دائماً
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showServiceArea)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isOutsideArea ? AppColors.error : AppColors.success),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              isOutsideArea
                                  ? 'خارج نطاق التوصيل'
                                  : 'داخل نطاق التوصيل',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Icon(Icons.location_pin,
                            size: 46,
                            color: isOutsideArea ? AppColors.error : AppColors.purple,
                            shadows: [
                              Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                            ]),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن عنوان أو حي أو معلم...',
                            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: _searching
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : Icon(Icons.search, color: AppColors.textHint),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close, size: 18, color: AppColors.textHint),
                                    onPressed: () => setState(() {
                                      _searchCtrl.clear();
                                      _searchResults = [];
                                    }),
                                  )
                                : null,
                          ),
                          onSubmitted: _searchAddress,
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          constraints: const BoxConstraints(maxHeight: 260),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: AppColors.surfaceLight),
                            itemBuilder: (_, i) {
                              final r = _searchResults[i];
                              return ListTile(
                                dense: true,
                                leading: Icon(Icons.location_on_outlined,
                                    color: AppColors.purple, size: 20),
                                title: Text(
                                  r.displayName,
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _selectSearchResult(r),
                              );
                            },
                          ),
                        )
                      else if (!_hasPicked && !_locating)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                          child: Text(
                            'ابحث عن عنوانك، أو حرّك الخريطة لتحديد موقعك بدقة، أو استخدم زر GPS',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: 'gps-locate',
                    backgroundColor: AppColors.surface,
                    onPressed: _locating ? null : _useCurrentLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.my_location, color: AppColors.purple),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.purple, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _reverseGeocoding
                          ? Text('جاري تحديد العنوان...',
                              style: TextStyle(color: AppColors.textHint, fontSize: 12))
                          : Text(
                              _detectedAddress ?? 'حرّك الخريطة لتحديد العنوان',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل إضافية (رقم المبنى، الدور، علامة مميزة...)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                if (isOutsideArea) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'هذا الموقع خارج نطاق التوصيل — اختر موقعاً أقرب للمطعم للمتابعة',
                            style: TextStyle(color: AppColors.error, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AppButton(
                  label: 'تأكيد الموقع',
                  icon: Icons.check_circle,
                  width: double.infinity,
                  color: isOutsideArea ? AppColors.textHint : null,
                  onPressed: isOutsideArea ? null : _confirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
