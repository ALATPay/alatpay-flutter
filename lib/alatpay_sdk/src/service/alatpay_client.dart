import 'service.dart';
import 'package:http/http.dart' as http;

class AlatPayClient extends BaseService {
  AlatPayClient({required String baseUrl, required String secretKey})
      : super(http.Client(), baseUrl, {
          "Content-Type": "application/json",
          "Ocp-Apim-Subscription-Key": secretKey,
        });

  Future<PaymentResult> pay({
    required PaymentChannel channel,
    required PaymentRequest request,
  }) async {
    switch (channel) {
      case PaymentChannel.web:
        return _initiateWebPayment(request);
      case PaymentChannel.bankTransfer:
        return _initiateBankTransfer(request);
      case PaymentChannel.ussd:
        return _initiateUssdPayment(request);
      case PaymentChannel.bankDetails:
        return _initiateBankDetailsPayment(request);
    }
  }

  Future<PaymentResult> _initiateWebPayment(PaymentRequest req) async {
    final body = await post('/alatpay/api/v1/checkout/initiate', {
      "businessId": req.businessId,
      "amount": req.amount,
      "currency": req.currency,
      "orderId": req.orderId,
      "description": req.description,
      "customer": req.customer.toJson(),
    });

    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "Error initiating payment",
      raw: body['data'],
    );
  }

  Future<PaymentResult> _initiateBankTransfer(PaymentRequest req) async {
    final body =
        await post('/bank-transfer/api/v1/bankTransfer/virtualAccount', {
      "businessId": req.businessId,
      "amount": req.amount,
      "currency": req.currency,
      "description": req.description,
      "customer": req.customer.toJson(),
    });

    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "",
      raw: body['data'],
    );
  }

  Future<PaymentResult> _initiateUssdPayment(PaymentRequest req) async {
    final body = await post(
      '/alatpay-phone-number/api/v1/phone-number-payment/initialize',
      {
        "businessId": req.businessId,
        "amount": req.amount,
        "currency": req.currency,
        "description": req.description,
        "customer": req.customer.toJson(),
        "phonenumber": req.customer.phone,
      },
    );

    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "",
      raw: body['data'],
    );
  }

  Future<PaymentResult> _initiateBankDetailsPayment(PaymentRequest req) async {
    final body =
        await post('/alatpayaccountnumber/api/v1/accountNumber/sendOtp', {
      "businessId": req.businessId,
      "amount": req.amount,
      "currency": req.currency,
      "description": req.description,
      "channel": "bank",
      "customer": req.customer.toJson(),
      "accountNumber": req.accountNumber,
      "bankCode": req.bankCode,
    });

    if (body['status'] == true) {
      return PaymentResult(
        success: true,
        message: "OTP sent to user phone",
        raw: {
          "transactionId": body['data']['transactionId'],
          "requiresOtp": true,
        },
      );
    }
    return PaymentResult(
      success: false,
      message: body['message'] ?? "Failed to send OTP",
    );
  }

  Future<PaymentResult> confirmOtp(String otp, String transactionId) async {
    final body = await post(
      '/alatpayaccountnumber/api/v1/accountNumber/validateAndPay',
      {"otp": otp, "transactionId": transactionId},
    );
    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "",
      raw: body['data'],
    );
  }

  Future<PaymentResult> confirmBankTransfer(String transactionId) async {
    final body = await get(
      '/bank-transfer/api/v1/bankTransfer/transactions/$transactionId',
    );
    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "Transaction pending",
      raw: body['data'],
    );
  }

  Future<PaymentResult> confirmUssd(
    PaymentRequest req,
    String transactionId,
  ) async {
    final body = await post(
      '/alatpay-phone-number/api/v1/phone-number-payment/complete-phonenumber-payment',
      {
        "phonenumber": req.customer.phone,
        "amount": req.amount,
        "businessid": req.businessId,
        "currency": req.currency,
        "transactionId": transactionId,
      },
    );

    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "",
      raw: body['data'],
    );
  }

  Future<PaymentResult> confirmBankDetails(
    String otp,
    String transactionId,
  ) async {
    final body = await post(
      '/alatpayaccountnumber/api/v1/accountNumber/validateAndPay',
      {"otp": otp, "transactionId": transactionId},
    );

    return PaymentResult(
      success: body['status'] == true,
      message: body['message'] ?? "",
      raw: body['data'],
    );
  }
}
