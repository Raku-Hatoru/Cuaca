/// Utilitas konversi suhu dan kategori metrik meteorologi dalam Bahasa Indonesia.
class TemperatureUtils {
  TemperatureUtils._();

  static double convert(double celsius, bool toFahrenheit) {
    if (!toFahrenheit) return celsius;
    return (celsius * 9 / 5) + 32;
  }

  static String format(
    double celsius, {
    bool toFahrenheit = false,
    bool withUnit = false,
  }) {
    final value = convert(celsius, toFahrenheit).round();
    if (!withUnit) return '$value°';
    return '$value°${toFahrenheit ? 'F' : 'C'}';
  }

  static String unitLabel(bool isFahrenheit) => isFahrenheit ? '°F' : '°C';

  static String windDirectionLabel(double degrees) {
    final normalized = ((degrees % 360) + 360) % 360;
    const directions = [
      'Utara (N)',
      'Timur Laut (NE)',
      'Timur (E)',
      'Tenggara (SE)',
      'Selatan (S)',
      'Barat Daya (SW)',
      'Barat (W)',
      'Barat Laut (NW)',
    ];
    final index = ((normalized + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  static String uvCategory(double uvIndex) {
    if (uvIndex < 3) return 'Rendah';
    if (uvIndex < 6) return 'Sedang';
    if (uvIndex < 8) return 'Tinggi';
    if (uvIndex < 11) return 'Sangat Tinggi';
    return 'Ekstrem';
  }

  static String pressureDescription(double pressureHpa) {
    if (pressureHpa < 1005) return 'Tekanan rendah';
    if (pressureHpa <= 1020) return 'Stabil dan normal';
    return 'Tekanan tinggi';
  }

  static String aqiCategory(int aqi) {
    if (aqi <= 20) return 'Sangat Baik';
    if (aqi <= 40) return 'Baik';
    if (aqi <= 60) return 'Sedang';
    if (aqi <= 80) return 'Kurang Sehat';
    return 'Tidak Sehat';
  }

  static String aqiAdvice(int aqi) {
    if (aqi <= 40) return 'Udara bersih, ideal untuk aktivitas luar ruang';
    if (aqi <= 60) return 'Aman untuk mayoritas orang';
    if (aqi <= 80) return 'Kelompok sensitif sebaiknya kurangi aktivitas berat';
    return 'Gunakan masker saat beraktivitas di luar ruangan';
  }
}
