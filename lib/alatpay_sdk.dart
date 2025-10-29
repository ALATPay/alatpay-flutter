// lib/alatpay_sdk.dart
import 'package:alatpay_sdk/alatpay_sdk/src/core/theme/alatpay_theme.dart';
import 'package:flutter/material.dart';

import 'alatpay_sdk/src/models/models.dart';
import 'alatpay_sdk/src/payments/alatpay_widget/alatpay_widget.dart';

// Re-export models so users don’t import internal paths
export 'alatpay_sdk/src/models/models.dart';

/// Main entry point for the AlatPay SDK.
class AlatPaySdk {
  /// Launches the AlatPay payment flow.
  ///
  /// Throws [ArgumentError] if the [request] is invalid.
  /// Returns a [Future] that completes when the payment flow is closed.
  static Future<void> startPayment(
    BuildContext context, {
    required PaymentRequest request,
    required String secretKey,
    AlatPayTheme? theme,
    String? branding,
    required Function(PaymentResult?) onPaymentComplete,
    required Function(String) onPaymentError,
  }) async {
    // Validate request
    if (request.businessId.isEmpty ||
        request.amount <= 0 ||
        secretKey.isEmpty) {
      throw ArgumentError('Invalid PaymentRequest: missing or invalid fields.');
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlatPayWidget(
            parentContext: context,
            request: request,
            secretKey: secretKey,
            onPaymentComplete: onPaymentComplete,
            onPaymentError: onPaymentError,
            branding: branding,
          ),
        ),
      );
    } catch (e) {
      // Handle navigation or widget errors
      debugPrint('AlatPaySdk navigation error: $e');
      rethrow;
    }
  }

  /// Cleans up any resources used by the SDK.
  ///
  /// Call this when the SDK is no longer needed.
  static void dispose() {
    // Add cleanup logic here if needed in the future.
  }
}
