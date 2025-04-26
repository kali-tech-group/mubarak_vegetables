import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mubarak_vegetables/screens/BottomNavigationScreen.dart';

class LocationUpdateScreen extends StatefulWidget {
  final String userPhone;
  const LocationUpdateScreen({required this.userPhone});

  @override
  State<LocationUpdateScreen> createState() => _LocationUpdateScreenState();
}

class _LocationUpdateScreenState extends State<LocationUpdateScreen> {
  late MapController _mapController;
  LatLng? _currentLatLng;
  String _address = '';
  bool _isLoading = false;

  Set<Marker> _markers = {};
  List<CircleMarker> _zoneCircles = [];

  final databaseRef = FirebaseDatabase.instance.ref("zones");

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
    _loadZonesFromFirebase();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Location permission is denied."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ Location permission permanently denied. Enable it in app settings.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      await _updateLocation(latLng);
      _mapController.move(latLng, 16);
    } catch (e) {
      print("Location fetch error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to fetch location."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation(LatLng point) async {
    try {
      setState(() => _isLoading = true);
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      final place = placemarks.first;
      setState(() {
        _currentLatLng = point;
        _address =
            "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
        _markers = {
          Marker(
            point: point,
            width: 80,
            height: 80,
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        };
      });
    } catch (e) {
      print("Geocoding failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadZonesFromFirebase() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as dynamic);
      setState(() {
        _zoneCircles =
            data.values.map((zone) {
              final lat = zone['lat'];
              final lng = zone['lng'];
              final radius = zone['radius'];
              return CircleMarker(
                point: LatLng(lat, lng),
                radius: radius.toDouble(),
                color: Colors.green.withOpacity(0.3),
                borderColor: Colors.green,
                borderStrokeWidth: 2,
              );
            }).toList();
      });
    }
  }

  bool _isUserInZone() {
    if (_currentLatLng == null) return false;
    final Distance distance = Distance();
    for (var circle in _zoneCircles) {
      final double dist = distance.as(
        LengthUnit.Meter,
        _currentLatLng!,
        circle.point,
      );
      if (dist <= circle.radius) return true;
    }
    return false;
  }

  void _saveLocation() async {
    if (_currentLatLng != null) {
      if (_isUserInZone()) {
        await FirebaseDatabase.instance
            .ref("users/${widget.userPhone}/location")
            .set({
              "lat": _currentLatLng!.latitude,
              "lng": _currentLatLng!.longitude,
              "address": _address,
            });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhone', widget.userPhone);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("📍 Location saved successfully.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ You are outside the delivery zone."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onTap: (tapPosition, point) async {
                await _updateLocation(point);
              },
              maxZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: _markers.toList()),
              CircleLayer(circles: _zoneCircles),
            ],
          ),

          if (_currentLatLng != null && !_isLoading) ...[
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Icon(Icons.place, color: Colors.green[800]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(_address, style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.green)),

          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _getUserLocation,
              icon: Icon(Icons.my_location),
              label: Text("Use Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text("Save Address"),
            ),
          ),
        ],
      ),
    );
  }
}
