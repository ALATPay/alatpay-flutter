import 'pages.dart';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key, this.branding});

  final String? branding;

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  final _controller = AlatPayController.instance;
  late final data = _controller.result?.raw;

  static const int _initialSeconds = 30 * 60;
  late int _secondsLeft = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlatPayController.instance.reset();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            navigator.currentState?.pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Complete Your Transfer",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBankCard(),
            const SizedBox(height: 24),
            _buildInfoRow(
              "Amount to Pay",
              "₦${data["amount"]}",
              highlight: true,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Please note that confirmation happens automatically within a few minutes once the transfer is detected.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _controller.confirmBankTransfer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _controller.status == PaymentStatus.confirmationLoading
                            ? CupertinoActivityIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : Text(
                                "I’ve Sent the Money",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                              ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Payment expires in ${_formatDuration(_secondsLeft)}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Image.asset(
              widget.branding ?? 'assets/images/alat-pay.png',
              package: widget.branding == null ? "alatpay_sdk" : null,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow("Bank Name", "Wema Bank", copyable: true),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Account Number",
            data["virtualBankAccountNumber"],
            copyable: true,
          ),
          const SizedBox(height: 12),
          if (data["description"] != null &&
              data["description"].toString().isNotEmpty)
            _buildInfoRow("Account Name", data["description"]),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool copyable = false,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: highlight ? 18 : 16,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? Colors.black87 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
            icon: const Icon(Icons.copy_rounded, size: 20),
          ),
      ],
    );
  }
}
