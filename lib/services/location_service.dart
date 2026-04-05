import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final String countryCode;
  final String countryName;

  const LocationResult({
    required this.countryCode,
    required this.countryName,
  });
}

class LocationService {
  /// Detect the user's country from GPS coordinates.
  /// Returns null if location cannot be determined.
  Future<LocationResult?> detectCountry() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Check/request permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Low accuracy is enough for country
        timeLimit: Duration(seconds: 10),
      ),
    );

    // Reverse geocode to get country
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;

    final placemark = placemarks.first;
    final countryCode = placemark.isoCountryCode;
    final countryName = placemark.country;

    if (countryCode == null || countryName == null) return null;

    return LocationResult(
      countryCode: countryCode.toUpperCase(),
      countryName: countryName,
    );
  }
}
