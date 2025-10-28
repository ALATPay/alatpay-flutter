import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';

/// Base exception for all AlatPay SDK errors.
class AlatPayException implements Exception {
  final String message;
  static String? lastMessage;

  AlatPayException([this.message = "Something went wrong"]) {
    lastMessage = message;
  }

  static void clear() {
    lastMessage = null;
  }

  @override
  String toString() => "AlatPayException: $message";

  /// Factory: converts a failed HTTP response into a readable SDK exception.
  factory AlatPayException.fromResponse(Response response) {
    log("❌ API Error Response: ${response.statusCode} ${response.body}");

    try {
      final decoded = jsonDecode(response.body);
      final msg = decoded['message'] ??
          decoded['error'] ??
          "Unknown server error (${response.statusCode})";

      if (response.statusCode >= 500) {
        return AlatPayServerException(msg);
      } else if (response.statusCode == 404) {
        final decode = jsonDecode(response.body);
        return AlatPayApiException(decode["message"] ?? "Resource not found");
      } else {
        return AlatPayApiException(msg);
      }
    } catch (_) {
      return AlatPayApiException(
        "Invalid response format (${response.statusCode})",
      );
    }
  }
}

/// Network or connectivity issue.
class AlatPayNetworkException extends AlatPayException {
  AlatPayNetworkException([super.message = "Network connection error"]);
}

/// Client- or API-side error (4xx responses).
class AlatPayApiException extends AlatPayException {
  AlatPayApiException([super.message = "API error"]);
}

/// Server-side error (5xx responses).
class AlatPayServerException extends AlatPayException {
  AlatPayServerException([super.message = "Server error"]);
}
