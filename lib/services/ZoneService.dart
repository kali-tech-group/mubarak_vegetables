import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ZoneService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("zones");

  // Function to add a zone to Firebase
  Future<void> addZone(
    String zoneName,
    double lat,
    double lng,
    double radius,
  ) async {
    try {
      await _databaseRef.child(zoneName).set({
        'lat': lat,
        'lng': lng,
        'radius': radius,
      });
      print("Zone $zoneName added successfully");
    } catch (e) {
      print("Error adding zone: $e");
    }
  }

  // Function to fetch all zones from Firebase
  Future<void> fetchZones() async {
    try {
      final snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        print("Zones: ${snapshot.value}");
      } else {
        print("No zones found");
      }
    } catch (e) {
      print("Error fetching zones: $e");
    }
  }
}

void addZones() {
  ZoneService zoneService = ZoneService();

  // Add the first zone (Bairnayakkampatty)
  String zoneName1 = "Bairnayakkampatty";
  double lat1 = 12.9736;
  double lng1 = 78.1459;
  double radius1 = 1500; // 1500 meters radius
  zoneService.addZone(zoneName1, lat1, lng1, radius1);

  // Add the second zone (Naripalli)
  String zoneName2 = "Naripalli";
  double lat2 = 13.0020;
  double lng2 = 78.2025;
  double radius2 = 1500; // 1500 meters radius
  zoneService.addZone(zoneName2, lat2, lng2, radius2);

  // Add the third zone (Sikkalur)
  String zoneName3 = "Sikkalur";
  double lat3 = 12.9528;
  double lng3 = 78.2501;
  double radius3 = 1500; // 1500 meters radius
  zoneService.addZone(zoneName3, lat3, lng3, radius3);
}

class ZoneHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zone Management')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the addZones function when button is pressed
            addZones();
          },
          child: Text('Add Zones'),
        ),
      ),
    );
  }
}
