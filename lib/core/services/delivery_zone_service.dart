import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/delivery_zone_model.dart';

class DeliveryZoneService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colZones = 'deliveryZones';

  static Stream<List<DeliveryZone>> streamZones() {
    return _db.collection(_colZones).snapshots().map((snap) {
      final zones =
          snap.docs.map((d) => DeliveryZone.fromMap(d.data(), d.id)).toList();
      zones.sort((a, b) => a.maxDistanceKm.compareTo(b.maxDistanceKm));
      return zones;
    });
  }

  static Future<void> addZone(DeliveryZone zone) async {
    await _db.collection(_colZones).add(zone.toMap());
  }

  static Future<void> updateZone(DeliveryZone zone) async {
    await _db.collection(_colZones).doc(zone.id).update(zone.toMap());
  }

  static Future<void> deleteZone(String id) async {
    await _db.collection(_colZones).doc(id).delete();
  }

  // المسافة بالكيلومترات بين نقطتين (خط مستقيم)
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  // أول نطاق تتسع مسافته لهذه المسافة (النطاقات مرتّبة تصاعدياً) — null يعني خارج نطاق التوصيل
  static DeliveryZone? resolveZone(List<DeliveryZone> zones, double distanceKm) {
    for (final z in zones) {
      if (distanceKm <= z.maxDistanceKm) return z;
    }
    return null;
  }
}
