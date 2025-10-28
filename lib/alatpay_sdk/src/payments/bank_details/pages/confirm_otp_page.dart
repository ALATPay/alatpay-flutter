import 'package:alatpay_sdk/alatpay_sdk/src/service/alatpay_exception.dart';

import 'pages.dart';

class ConfirmOtpPage extends StatelessWidget {
  ConfirmOtpPage({super.key, required this.amount});

  final String amount;
  final _controller = AlatPayController.instance;

  late final data = _controller.result?.raw;

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
        leading: InkWell(
          onTap: () {
            navigator.currentState?.pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 70,
                ),
                const SizedBox(height: 20),
                Text(
                  'Debit Initiated',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'A debit of ₦$amount has been initiated on your account '
                  '${data["phoneNumber"]}. Please confirm this transaction by entering '
                  'the OTP sent to your phone number.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return ElevatedButton(
                            onPressed: () {
                              _controller.confirmOtp(otpController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _controller.status == PaymentStatus.loading
                                ? CupertinoActivityIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  )
                                : Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          navigator.currentState?.pop();
                          _controller.reset();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            // ✅ This is the visible border
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
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
