abstract class ApiConstants {
  static const String baseUrl = 'http://192.168.100.78:8002';
  static const String swaggerUrl = 'http://192.168.100.78:8002/docs';

  // Endpoints
  static const String health = '/api/health';
  static const String request = '/api/request';
  static const String requestAudio = '/api/request/audio';
  static const String bookings = '/api/bookings';
  static String trace(String bookingId) => '/api/trace/$bookingId';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
