/// Eksepsi domain aplikasi cuaca dengan pesan ramah pengguna dalam Bahasa Indonesia.
class AppException implements Exception {
  const AppException(this.message, {this.isNetworkError = false});

  final String message;
  final bool isNetworkError;

  @override
  String toString() => message;
}
