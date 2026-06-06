import 'mock_omr_service.dart';
import 'omr_service.dart';
import 'remote_omr_service.dart';

/// Derleme zamanı yapılandırması.
class AppConfig {
  const AppConfig._();

  /// OMR backend URL'i. `--dart-define=OMR_BASE_URL=...` ile verilir.
  /// Boşsa uygulama offline mock'a düşer.
  static const String omrBaseUrl =
      String.fromEnvironment('OMR_BASE_URL', defaultValue: '');

  static bool get hasRemoteOmr => omrBaseUrl.isNotEmpty;

  /// Yapılandırmaya göre uygun OMR servisini döndürür.
  static OmrService buildOmrService() {
    if (hasRemoteOmr) {
      return RemoteOmrService(baseUrl: omrBaseUrl);
    }
    return MockOmrService();
  }
}
