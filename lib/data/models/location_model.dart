/// Model data lokasi kota dari Open-Meteo Geocoding API dan penyimpanan lokal.
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.countryCode,
    required this.admin1,
    required this.timezone,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String admin1;
  final String timezone;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ??
              Object.hash(json['name'], lat, lon);

    return LocationModel(
      id: parsedId,
      name: (json['name'] as String?)?.trim() ?? 'Tidak diketahui',
      latitude: lat,
      longitude: lon,
      country: (json['country'] as String?)?.trim() ?? '',
      countryCode: (json['country_code'] as String?)?.trim() ?? '',
      admin1: (json['admin1'] as String?)?.trim() ?? '',
      timezone: (json['timezone'] as String?)?.trim() ?? 'auto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  /// Subjudul ringkas berisi provinsi/wilayah dan negara.
  String get subtitle {
    final parts = <String>[];
    if (admin1.isNotEmpty && admin1.toLowerCase() != name.toLowerCase()) {
      parts.add(admin1);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    if (parts.isEmpty) {
      return coordinatesLabel;
    }
    return parts.join(', ');
  }

  /// Label pendek untuk header lokasi di AppBar.
  String get headerLabel {
    if (countryCode.isNotEmpty) {
      return '$name, $countryCode';
    }
    if (admin1.isNotEmpty) {
      return '$name, $admin1';
    }
    return name;
  }

  String get coordinatesLabel {
    final latDir = latitude >= 0 ? 'LU' : 'LS';
    final lonDir = longitude >= 0 ? 'BT' : 'BB';
    return '${latitude.abs().toStringAsFixed(2)}°$latDir ${longitude.abs().toStringAsFixed(2)}°$lonDir';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
