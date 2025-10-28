import 'package:alatpay_sdk/alatpay_sdk/src/service/alatpay_exception.dart';

import 'controller.dart';

class AlatPayController extends ChangeNotifier {
  // --- 🔒 Singleton Implementation ---
  static final AlatPayController _instance = AlatPayController._internal();

  factory AlatPayController() => _instance;

  AlatPayController._internal();

  static AlatPayController get instance => _instance;

  // --- 🧩 SDK Instance ---
  late final AlatPayClient _sdk;
  bool _initialized = false;

  void initialize(AlatPayClient sdk) {
    if (!_initialized) {
      _sdk = sdk;
      _initialized = true;
    }
  }

  // --- ⚡ State Variables ---
  PaymentStatus _status = PaymentStatus.idle;

  PaymentStatus get status => _status;

  PaymentResult? _result;

  PaymentResult? get result => _result;

  PaymentChannel? _channel;

  PaymentChannel? get channel => _channel;

  // --- 🔁 Internal State Updaters ---
  void _setStatus(PaymentStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setChannel(PaymentChannel c) {
    _channel = c;
    notifyListeners();
  }

  // --- 💳 Payment Logic ---
  void _ensureInitialized() {
    if (!_initialized) {
      throw AlatPayException(
        "❌ AlatPay SDK not initialized. Please call initialize() before performing this action.",
      );
    }
  }

  Future<void> pay({
    required PaymentChannel channel,
    required PaymentRequest request,
  }) async {
    _ensureInitialized();
    _setStatus(PaymentStatus.loading);
    _setChannel(channel);

    try {
      final res = await _sdk.pay(channel: channel, request: request);
      _result = res;

      if (res.success && channel == PaymentChannel.bankTransfer) {
        _setStatus(PaymentStatus.waitingForConfirmation);
        startBackgroundBankTransferCheck();
      } else if (res.success && channel == PaymentChannel.ussd) {
        _setStatus(PaymentStatus.waitingForConfirmation);
      } else if (res.success && res.raw?['requiresOtp'] == true) {
        _setStatus(PaymentStatus.waitingForOtp);
      } else {
        _setStatus(res.success ? PaymentStatus.success : PaymentStatus.failed);
      }
    } catch (e) {
      if (channel == PaymentChannel.bankDetails) {
        _setStatus(PaymentStatus.idle);
      } else {
        _setStatus(PaymentStatus.failed);
      }
    }
  }

  Future<void> confirmOtp(String otp) async {
    if (!_initialized) {
      throw Exception(
        "❌ PaymentController not initialized. Call initialize() first.",
      );
    }

    _setStatus(PaymentStatus.loading);

    final txId = _result?.raw?['transactionId'];
    if (txId == null) {
      _setStatus(PaymentStatus.failed);
      return;
    }

    try {
      final res = await _sdk.confirmOtp(otp, txId);

      if (res.success) {
        _result = res;
        _setStatus(PaymentStatus.success);
      } else {
        _setStatus(PaymentStatus.failed);
        throw AlatPayApiException(res.message);
      }
    } on AlatPayException {
      _setStatus(PaymentStatus.waitingForOtp);
    } catch (e) {
      _setStatus(PaymentStatus.failed);
      rethrow; // optional if you want the caller to handle it further
    }
  }

  Future<void> confirmBankTransfer() async {
    _ensureInitialized();

    // Must have a current payment result before confirming
    if (_result == null || _result?.raw["transactionId"] == null) {
      throw AlatPayException("No pending bank transfer to confirm.");
    }

    final ref = _result?.raw["transactionId"];

    _setStatus(PaymentStatus.confirmationLoading);

    try {
      // 👇 Call SDK client confirmation endpoint
      final res = await _sdk.confirmBankTransfer(ref);

      if (res.success) {
        _setStatus(PaymentStatus.success);
      } else {
        _setStatus(PaymentStatus.failed);
        throw AlatPayApiException(res.message);
      }
    } on AlatPayException {
      _setStatus(PaymentStatus.waitingForConfirmation);
    } catch (e) {
      _setStatus(PaymentStatus.failed);
      rethrow;
    }
  }

  /// 🏦 Confirm Ussd Transfer Payment

  Future<void> confirmUssd() async {
    _ensureInitialized();

    final txId = _result?.raw?['transactionId'];
    if (txId == null) {
      _setStatus(PaymentStatus.failed);
      throw AlatPayException("No pending USSD payment to confirm.");
    }

    _setStatus(PaymentStatus.confirmationLoading);

    try {
      final raw = _result?.raw;
      final res = await _sdk.confirmUssd(
        PaymentRequest(
          businessId: raw["businessId"],
          amount: raw["amount"],
          currency: raw["currency"],
          orderId: "",
          description: "",
          customer: Customer(
            email: "",
            phone: raw["phoneNumber"],
            firstName: "",
            lastName: "",
          ),
        ),
        txId,
      );

      if (res.success) {
        _result = res;
        _setStatus(PaymentStatus.success);
        stopBackgroundCheck();
      } else {
        _setStatus(PaymentStatus.failed);
        throw AlatPayApiException(res.message);
      }
    } on AlatPayException {
      _setStatus(PaymentStatus.waitingForConfirmation);
    } catch (e) {
      _setStatus(PaymentStatus.failed);
      rethrow; // Optional: rethrow so upper layers can still catch it
    }
  }

  /// 🧩 Background Auto Confirmation for Bank Transfer
  Timer? _backgroundTimer;

  void startBackgroundBankTransferCheck() {
    // Cancel any existing timer to avoid duplicates
    _backgroundTimer?.cancel();

    // Wait 10 seconds before first check
    _backgroundTimer = Timer(const Duration(seconds: 10), () {
      _pollQuietly();
    });
  }

  Future<void> _pollQuietly() async {
    final txId = _result?.raw?['transactionId'];
    if (txId == null || !_initialized) return;

    // Background polling every 5 seconds
    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      try {
        final res = await _sdk.confirmBankTransfer(txId);

        if (res.success) {
          _result = res;
          _setStatus(PaymentStatus.success);
          timer.cancel(); // ✅ Stop once success
        } else {}
      } catch (_) {
        // Ignore background errors silently
      }
    });
  }

  void stopBackgroundCheck() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  // --- 🔄 Reset State ---
  void reset() {
    _status = PaymentStatus.idle;
    _result = null;
    _channel = null;
    stopBackgroundCheck();
    notifyListeners();
  }
}
