import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_zone_model.dart';
import '../services/delivery_zone_service.dart';

final deliveryZonesProvider = StreamProvider<List<DeliveryZone>>((ref) {
  return DeliveryZoneService.streamZones();
});
