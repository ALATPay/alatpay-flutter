import 'package:alatpay_sdk/alatpay_sdk/src/service/alatpay_exception.dart';

import 'pages.dart';

class BankSelectionPage extends StatefulWidget {
  const BankSelectionPage({super.key, required this.request});

  final PaymentRequest request;

  @override
  State<BankSelectionPage> createState() => _BankSelectionPageState();
}

class _BankSelectionPageState extends State<BankSelectionPage> {
  final _controller = AlatPayController.instance;

  late Future<void> _loadFuture;
  final ValueNotifier<List<Bank>> _banks = ValueNotifier([]);
  final ValueNotifier<List<Bank>> _filteredBanks = ValueNotifier([]);
  final ValueNotifier<Bank?> _selectedBank = ValueNotifier(null);
  final ValueNotifier<bool?> _resolved = ValueNotifier(null);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  String _accountNumber = '';

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadBanks();
    AlatPayException.clear();
  }

  Future<void> _loadBanks() async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/alatpay_sdk/assets/banks/banks.json',
      );
      final data = jsonDecode(jsonString);
      final List banks = data['banks'] ?? [];
      final parsed = banks.map((e) => Bank.fromJson(e)).toList();
      _banks.value = parsed;
      _filteredBanks.value = parsed;
    } catch (e) {
      debugPrint("Error loading banks: $e");
    }
  }

  void _filterBanks(String query) {
    final all = _banks.value;
    final filtered = all
        .where((b) => b.bankName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _filteredBanks.value = filtered;
  }

  Future<void> _resolveAccount() async {
    if (_accountNumber.length != 10) return;
    _resolved.value = true;
  }

  Future<void> _pay(PaymentChannel channel) async {
    _controller.reset();
    final paymentRequest = widget.request.copyWith(
      accountNumber: _accountNumber,
      bankCode: _selectedBank.value?.scCode,
    );
    await _controller.pay(channel: channel, request: paymentRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Bank'),
        leading: InkWell(
          onTap: () {
            navigator.currentState?.pop();
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load banks."));
          }

          return ValueListenableBuilder<Bank?>(
            valueListenable: _selectedBank,
            builder: (context, selected, _) {
              return selected == null ? _buildBankList() : _buildAccountInput();
            },
          );
        },
      ),
    );
  }

  Widget _buildBankList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search bank...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _filterBanks,
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Bank>>(
            valueListenable: _filteredBanks,
            builder: (context, banks, _) {
              return ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(bank.imageUrl),
                      backgroundColor: Colors.white,
                    ),
                    title: Text(bank.bankName),
                    onTap: () => _selectedBank.value = bank,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(_selectedBank.value!.imageUrl),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _selectedBank.value!.bankName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _selectedBank.value = null;
                  _filteredBanks.value = _banks.value;
                  _resolved.value = false;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter Account Number',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0123456789',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _accountNumber = value;
              if (value.length == 10) {
                _resolveAccount();
              } else {
                _resolved.value = false;
              }
            },
          ),
          const SizedBox(height: 30),
          ValueListenableBuilder<bool>(
            valueListenable: _loading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ValueListenableBuilder<bool?>(
                valueListenable: _resolved,
                builder: (context, resolved, _) {
                  if (resolved ?? false) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return Column(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: _controller.status ==
                                          PaymentStatus.loading
                                      ? CupertinoActivityIndicator(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        )
                                      : Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    _pay(PaymentChannel.bankDetails);
                                  },
                                ),
                                SizedBox(height: 24),
                                if ((AlatPayException.lastMessage ?? "")
                                    .isNotEmpty)
                                  Card(
                                    color: Colors.red.shade50,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        AlatPayException.lastMessage ?? "",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
