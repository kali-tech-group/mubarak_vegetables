import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _savedAddresses = [];

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get savedAddresses => [..._savedAddresses];

  // Initialize location services
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _checkPermission();
      await _getCurrentLocation();
      await _loadSavedAddresses();
    } catch (e) {
      _error = 'Failed to initialize location services: ${e.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check and request location permissions
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled';
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied';
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _error = 'Location permissions are denied';
        return false;
      }
    }
    return true;
  }

  // Get current device location
  Future<void> _getCurrentLocation() async {
    try {
      if (!await _checkPermission()) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      await _getAddressFromLatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _selectedLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _selectedAddress = _currentAddress;
    } catch (e) {
      _error = 'Failed to get current location: ${e.toString()}';
      if (kDebugMode) print(_error);
    }
  }

  // Convert coordinates to address
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return;

      Placemark place = placemarks[0];
      _currentAddress =
          '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';

      notifyListeners();
    } catch (e) {
      _error = 'Failed to get address: ${e.toString()}';
      if (kDebugMode) print(_error);
    }
  }

  // Convert address to coordinates
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      return LatLng(locations[0].latitude, locations[0].longitude);
    } catch (e) {
      _error = 'Failed to get coordinates: ${e.toString()}';
      if (kDebugMode) print(_error);
      return null;
    }
  }

  // Update selected location
  Future<void> updateSelectedLocation(LatLng newLocation) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedLocation = newLocation;
      await _getAddressFromLatLng(newLocation.latitude, newLocation.longitude);
      _selectedAddress = _currentAddress;
    } catch (e) {
      _error = 'Failed to update location: ${e.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save address to local storage
  Future<void> saveAddress({
    required String address,
    required LatLng location,
    required String type, // home/work/other
    String? tag,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newAddress = {
        'id': DateTime.now().toString(),
        'address': address,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'type': type,
        'tag': tag,
        'isDefault': _savedAddresses.isEmpty, // First address is default
      };

      _savedAddresses.add(newAddress);
      // Here you would typically save to Firestore or local DB
    } catch (e) {
      _error = 'Failed to save address: ${e.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load saved addresses
  Future<void> _loadSavedAddresses() async {
    try {
      // Simulate loading from database
      await Future.delayed(const Duration(seconds: 1));
      // In real app, load from Firestore/shared_preferences
    } catch (e) {
      _error = 'Failed to load addresses: ${e.toString()}';
      if (kDebugMode) print(_error);
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      _savedAddresses =
          _savedAddresses.map((address) {
            return {...address, 'isDefault': address['id'] == addressId};
          }).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set default address: ${e.toString()}';
      if (kDebugMode) print(_error);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
