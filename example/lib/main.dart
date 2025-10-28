import 'package:alatpay_sdk/alatpay_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    Customer demoCustomer = Customer(
      email: "jane.doe@email.com",
      phone: "09038818841",
      firstName: "Jane",
      lastName: "Doe",
    );
    final request = PaymentRequest(
      businessId: "631a3808-02a6-4d08-5e85-08dd9cdc577f",
      amount: 100,
      currency: "NGN",
      customer: demoCustomer,
    );
    AlatPaySdk.startPayment(
      context,
      request: request,
      secretKey: "c9ab87f3bcbb44faae8bccf944a0302a",
      onPaymentComplete: (result) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Successful payment ${result?.message}"),
          ),
        );
      },
      onPaymentError: (panic) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(panic.toString()),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _incrementCounter,
          child: const Text('Start AlatPay Payment'),
        ),
      ),
    );
  }
}
