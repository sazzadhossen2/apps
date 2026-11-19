/// Normalised result of every API call.
class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic data;
  final String message;
  final List<String> errors;

  /// Machine readable error code from the API (e.g. EMAIL_NOT_VERIFIED, OTP_INVALID).
  final String? code;

  const NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.message = '',
    this.errors = const [],
    this.code,
  });

  /// Best message to show to the user.
  String get errorMessage => errors.isNotEmpty ? errors.first : message;

  bool get isNetworkError => statusCode == -1;
}

extension NetworkResponseX on NetworkResponse {
  Map<String, dynamic> get dataMap =>
      data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};

  List<Map<String, dynamic>> listOf(String key) {
    final v = dataMap[key];
    if (v is! List) return [];
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
