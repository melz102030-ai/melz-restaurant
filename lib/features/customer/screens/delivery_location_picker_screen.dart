import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';

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
class DeliveryLocationPickerScreen extends StatefulWidget {
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
  State<DeliveryLocationPickerScreen> createState() =>
      _DeliveryLocationPickerScreenState();
}

class _DeliveryLocationPickerScreenState
    extends State<DeliveryLocationPickerScreen> {
  final _mapController = MapController();
  final _noteCtrl = TextEditingController();
  // الرياض كموقع افتراضي عند عدم توفر GPS أو موقع سابق
  ll.LatLng _center = const ll.LatLng(24.7136, 46.6753);
  bool _locating = false;
  bool _hasPicked = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl.text = widget.initialNote ?? '';
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = ll.LatLng(widget.initialLat!, widget.initialLng!);
      _hasPicked = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation());
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
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

  void _confirm() {
    Navigator.pop(
      context,
      DeliveryLocationResult(
        lat: _center.latitude,
        lng: _center.longitude,
        addressNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد موقع التوصيل'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
                        _center = center;
                        if (!_hasPicked) setState(() => _hasPicked = true);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.melz.restaurant',
                    ),
                  ],
                ),
                // دبوس ثابت في منتصف الشاشة — الموقع المختار هو مركز الخريطة دائماً
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38),
                    child: Icon(Icons.location_pin,
                        size: 46, color: AppColors.purple, shadows: [
                      Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                    ]),
                  ),
                ),
                if (!_hasPicked && !_locating)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Text(
                        'حرّك الخريطة لتحديد موقعك بدقة، أو استخدم زر GPS',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
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
                        : const Icon(Icons.my_location, color: AppColors.purple),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _noteCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل إضافية (رقم المبنى، الدور، علامة مميزة...)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'تأكيد الموقع',
                  icon: Icons.check_circle,
                  width: double.infinity,
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
