class PaymentResult {
  final bool success;
  final String message;
  final dynamic raw;

  PaymentResult({required this.success, required this.message, this.raw});
}
