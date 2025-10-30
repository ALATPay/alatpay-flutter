class PaymentRequest {
  final String businessId;
  final double amount;
  final String currency;
  final String? description;
  final Customer customer;

  /// Optional for bank details
  final String? accountNumber;
  final String? bankCode;
  final String orderId;

  PaymentRequest({
    required this.businessId,
    required this.amount,
    this.currency = "NGN",
    this.orderId = "",
    this.description = "",
    required this.customer,
    this.accountNumber,
    this.bankCode,
  });

  PaymentRequest copyWith({
    String? businessId,
    double? amount,
    String? currency,
    String? description,
    Customer? customer,
    String? accountNumber,
    String? bankCode,
    String? orderId,
  }) {
    return PaymentRequest(
      businessId: businessId ?? this.businessId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      customer: customer ?? this.customer,
      accountNumber: accountNumber ?? this.accountNumber,
      bankCode: bankCode ?? this.bankCode,
      orderId: orderId ?? this.orderId,
    );
  }
}

class Customer {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String? metadata;

  Customer({
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "phone": phone,
        "firstName": firstName,
        "lastName": lastName,
        "metadata": metadata ?? "",
      };
}
