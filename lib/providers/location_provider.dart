import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';

class LocationState {
  final String? countryCode;
  final String? countryName;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.countryCode,
    this.countryName,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    String? countryCode,
    String? countryName,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const LocationState());

  Future<void> detectLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _locationService.detectCountry();
      if (result != null) {
        state = state.copyWith(
          countryCode: result.countryCode,
          countryName: result.countryName,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not determine location',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Location access denied',
      );
    }
  }

  void setCountry(String code, String name) {
    state = state.copyWith(
      countryCode: code,
      countryName: name,
      isLoading: false,
      error: null,
    );
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(ref.read(locationServiceProvider)),
);
