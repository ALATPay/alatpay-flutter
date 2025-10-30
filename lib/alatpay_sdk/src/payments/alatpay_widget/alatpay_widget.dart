import 'package:alatpay_sdk/alatpay_sdk/src/service/alatpay_exception.dart';

import 'alatpay.dart';

final navigator = GlobalKey<NavigatorState>();

class AlatPayWidget extends StatefulWidget {
  final PaymentRequest request;
  final String secretKey;
  final BuildContext parentContext;
  final AlatPayTheme? alatPayTheme;
  final Function(PaymentResult? result) onPaymentComplete;
  final Function(String error) onPaymentError;
  final String? branding;

  const AlatPayWidget({
    super.key,
    required this.request,
    required this.secretKey,
    required this.parentContext,
    this.alatPayTheme,
    required this.onPaymentComplete,
    required this.onPaymentError,
    this.branding,
  });

  @override
  State<AlatPayWidget> createState() => _AlatPayWidgetState();
}

class _AlatPayWidgetState extends State<AlatPayWidget> {
  bool _isInitialized = false;

  void _onPop() {
    Navigator.of(widget.parentContext).pop();
  }

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  Future<void> _initializeSdk() async {
    WidgetsFlutterBinding.ensureInitialized();

    final alat = AlatPayClient(
      baseUrl: "https://apibox.alatpay.ng",
      secretKey: widget.secretKey,
    );

    AlatPayController.instance.initialize(alat);
    AlatPayController.instance.addListener(_onStateChange);

    // Wait a bit or confirm setup done (optional)
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    AlatPayController.instance.removeListener(_onStateChange);
    AlatPayController.instance.reset();
    super.dispose();
  }

  final ThemeData defaultTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Theme(
      data: (widget.alatPayTheme ?? AlatPayTheme.defaultTheme).toThemeData(),
      child: PopScope(
        canPop: false, // we handle back behavior ourselves
        onPopInvokedWithResult: (didPop, result) async {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(widget.parentContext).canPop()) {
              Navigator.of(widget.parentContext).pop();
            }
          });
        },
        child: Navigator(
          key: navigator,
          observers: [RouteTracker.instance],
          initialRoute: '/',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/':
                page = PaymentHomePage(request: widget.request, onPop: _onPop);
                break;
              case '/bank-transfer':
                page = BankTransferPage(
                  branding: widget.branding,
                );
                break;
              case '/ussd-confirmation':
                page = UssdConfirmationPage();
                break;
              case '/otp-page':
                page = ConfirmOtpPage(amount: widget.request.amount.toString());
                break;
              case '/bank-selection':
                page = BankSelectionPage(request: widget.request);
                break;
              default:
                page = PaymentHomePage(request: widget.request, onPop: _onPop);
            }

            return MaterialPageRoute(builder: (_) => page, settings: settings);
          },
        ),
      ),
    );
  }

  PaymentStatus? _lastHandledStatus;

  void _onStateChange() {
    final controller = AlatPayController.instance;
    final currentRoute = RouteTracker.instance.currentRoute;
    if (_lastHandledStatus == controller.status) return;
    _lastHandledStatus = controller.status;

    switch (controller.status) {
      case PaymentStatus.waitingForConfirmation:
        if (controller.channel == PaymentChannel.bankTransfer &&
            currentRoute != '/bank-transfer') {
          navigator.currentState?.pushNamed('/bank-transfer');
        } else if (controller.channel == PaymentChannel.ussd &&
            currentRoute != '/ussd-confirmation') {
          navigator.currentState?.pushNamed('/ussd-confirmation');
        }
        break;
      case PaymentStatus.waitingForOtp:
        if (controller.channel == PaymentChannel.bankDetails &&
            currentRoute != '/otp-page') {
          navigator.currentState?.pushNamed('/otp-page');
        }
        break;
      case PaymentStatus.success:
        widget.onPaymentComplete(AlatPayController.instance.result);
        break;
      case PaymentStatus.failed:
        widget.onPaymentError(AlatPayException.lastMessage ?? "Payment failed");
        break;
      default:
        break;
    }
  }
}
