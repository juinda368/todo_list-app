class ApiConfig {
  static const String defaultBaseUrl = 'http://49.232.224.106:5000'; // TC Server
  static const int timeout = 10000;

  static String getBaseUrl(String? customUrl) {
    return customUrl ?? defaultBaseUrl;
  }
}
