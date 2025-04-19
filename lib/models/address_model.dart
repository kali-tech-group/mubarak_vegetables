import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryAddress {
  final String id;
  final String address;
  final LatLng location;
  final String type; // home/work/other
  final String? tag;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.address,
    required this.location,
    required this.type,
    this.tag,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      id: map['id'] ?? '',
      address: map['address'] ?? '',
      location: LatLng(map['latitude'] ?? 0.0, map['longitude'] ?? 0.0),
      type: map['type'] ?? 'home',
      tag: map['tag'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type,
      'tag': tag,
      'isDefault': isDefault,
    };
  }
}
