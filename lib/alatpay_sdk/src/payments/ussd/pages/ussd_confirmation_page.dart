import 'package:alatpay_sdk/alatpay_sdk/src/service/alatpay_exception.dart';

import 'pages.dart';

class UssdConfirmationPage extends StatelessWidget {
  UssdConfirmationPage({super.key});

  final _controller = AlatPayController.instance;
  late final data = _controller.result?.raw;

  @override
  Widget build(BuildContext context) {
    final amount = data["amount"];
    final number = data["phoneNumber"];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            navigator.currentState?.pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: const Text('Confirm USSD Payment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_iphone,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Transaction Initiated",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "A USSD payment of ₦${amount.toStringAsFixed(2)} has been initiated on:",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          number,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Please complete the payment using your mobile device.\n"
                          "If you did not initiate this request, click Cancel.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  navigator.currentState?.pop();
                                  _controller.reset();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, _) {
                                return Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _controller.confirmUssd();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _controller.status ==
                                            PaymentStatus.confirmationLoading
                                        ? CupertinoActivityIndicator(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          )
                                        : const Text(
                                            "Proceed",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    if ((AlatPayException.lastMessage ?? "").isNotEmpty) {
                      return Card(
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: Icon(Icons.error, color: Colors.red),
                          title: Text(
                            AlatPayException.lastMessage ?? "",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
