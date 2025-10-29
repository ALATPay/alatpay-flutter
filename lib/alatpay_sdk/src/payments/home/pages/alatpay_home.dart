import 'pages.dart';

class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const PaymentMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Theme.of(context).primaryColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentHomePage extends StatefulWidget {
  const PaymentHomePage({
    super.key,
    required this.request,
    required this.onPop,
  });

  final PaymentRequest request;
  final VoidCallback onPop;

  @override
  State<PaymentHomePage> createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends State<PaymentHomePage> {
  late final AlatPayController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AlatPayController.instance;
  }

  void _pay(PaymentChannel channel) async {
    _controller.reset();
    await _controller.pay(channel: channel, request: widget.request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          "Choose your payment method",
          style: TextStyle(fontSize: 16),
        ),
        leading: InkWell(onTap: widget.onPop, child: Icon(Icons.arrow_back)),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.status == PaymentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaymentMethodButton(
                  icon: Icons.account_balance,
                  label: "Bank Transfer",
                  onPressed: () => _pay(PaymentChannel.bankTransfer),
                ),
                PaymentMethodButton(
                  icon: Icons.phone,
                  label: "USSD",
                  onPressed: () => _pay(PaymentChannel.ussd),
                ),
                PaymentMethodButton(
                  icon: Icons.credit_card,
                  label: "Bank Details (OTP)",
                  onPressed: () =>
                      navigator.currentState?.pushNamed('/bank-selection'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Powered by",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      "assets/images/alat-pay.png",
                      package: "alatpay_sdk",
                      height: 40,
                      width: 40,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
