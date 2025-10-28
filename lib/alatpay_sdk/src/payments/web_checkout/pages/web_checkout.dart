// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'models.dart';
//
// class AlatPayCheckout extends StatefulWidget {
//   final PaymentRequest request;
//   final String secretKey;
//   final Function(dynamic response) onTransaction;
//   final Function()? onClose;
//
//   const AlatPayCheckout({
//     super.key,
//     required this.request,
//     required this.secretKey,
//     required this.onTransaction,
//     this.onClose,
//   });
//
//   @override
//   State<AlatPayCheckout> createState() => _AlatPayCheckoutState();
// }
//
// class _AlatPayCheckoutState extends State<AlatPayCheckout> {
//   late final WebViewController _controller;
//   bool _isLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPaymentPage();
//   }
//
//   Future<void> _loadPaymentPage() async {
//     final r = widget.request;
//
//     final meta = r.customer.metadata == null
//         ? ''
//         : Uri.encodeComponent(jsonEncode(r.customer.metadata));
//
//     // Build URL query string dynamically
//     final params = {
//       'apiKey': widget.secretKey,
//       'secretKey': widget.secretKey,
//       'businessId': r.businessId,
//       'email': r.customer.email,
//       'phone': r.customer.phone ?? '',
//       'firstName': r.customer.firstName ?? '',
//       'lastName': r.customer.lastName ?? '',
//       'currency': r.currency ?? 'NGN',
//       'amount': r.amount.toString(),
//       'metaData': meta,
//     };
//
//     final query = params.entries
//         .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
//         .join('&');
//
//     // Inline HTML (your provided version)
//     final html = """
// <!DOCTYPE html>
// <html lang="en">
// <head>
//   <meta charset="UTF-8" />
//   <meta name="viewport"
//         content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
//   <title>AlatPay Checkout</title>
//   <script src="https://web.alatpay.ng/js/alatpay.js"></script>
// </head>
// <body>
//   <script>
//     const params = new URLSearchParams('$query');
//     const apiKey = params.get("apiKey");
//     const secretKey = params.get("secretKey");
//     const businessId = params.get("businessId");
//     const email = params.get("email");
//     const phone = params.get("phone");
//     const firstName = params.get("firstName");
//     const lastName = params.get("lastName");
//     const currency = params.get("currency");
//     const amount = Number(params.get("amount") || 0);
//     const meta = params.get("metaData");
//     const metaData = meta ? JSON.parse(decodeURIComponent(meta)) : null;
//
//     const popup = Alatpay.setup({
//       apiKey,
//       secretKey,
//       businessId,
//       email,
//       phone,
//       firstName,
//       lastName,
//       currency,
//       amount,
//       metaData,
//       onTransaction: (resp) => {
//         if (window.AlBridge) {
//           AlBridge.postMessage(JSON.stringify({ type: "success", data: resp }));
//         }
//       },
//       onClose: () => {
//         if (window.AlBridge) {
//           AlBridge.postMessage(JSON.stringify({ type: "cancel" }));
//         }
//       },
//     });
//
//     popup.show();
//   </script>
// </body>
// </html>
// """;
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..addJavaScriptChannel(
//         'AlBridge',
//         onMessageReceived: (msg) {
//           try {
//             final decoded = jsonDecode(msg.message);
//             if (decoded['type'] == 'success') {
//               widget.onTransaction(decoded['data']);
//             } else if (decoded['type'] == 'cancel') {
//               widget.onClose?.call();
//             }
//           } catch (e) {
//             debugPrint('⚠️ JS decode error: $e');
//           }
//         },
//       )
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) => debugPrint('🌍 Loading: $url'),
//           onPageFinished: (url) {
//             setState(() => _isLoaded = true);
//             debugPrint('✅ Page loaded');
//           },
//           onWebResourceError: (err) =>
//               debugPrint('🚨 WebView error: ${err.description}'),
//         ),
//       )
//       ..loadHtmlString(html);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (!_isLoaded)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'models.dart';
// //
// // class AlatPayCheckout extends StatefulWidget {
// //   final PaymentRequest request;
// //   final String secretKey;
// //   final Function(dynamic response) onTransaction;
// //   final Function()? onClose;
// //
// //   const AlatPayCheckout({
// //     super.key,
// //     required this.request,
// //     required this.secretKey,
// //     required this.onTransaction,
// //     this.onClose,
// //   });
// //
// //   @override
// //   State<AlatPayCheckout> createState() => _AlatPayCheckoutState();
// // }
// //
// // class _AlatPayCheckoutState extends State<AlatPayCheckout> {
// //   late final WebViewController _controller;
// //   bool _isLoaded = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeWebView();
// //   }
// //
// //   void _initializeWebView() {
// //     final req = widget.request;
// //     final metaData = req.customer.metadata == null ? 'null' : jsonEncode(req.customer.metadata);
// //     final apiKey = '"${widget.secretKey}"';
// //     final businessId = '"${req.businessId}"';
// //     final email = '"${req.customer.email}"';
// //     final phone = '"${req.customer.phone}"';
// //     final firstName = '"${req.customer.firstName}"';
// //     final lastName = '"${req.customer.lastName}"';
// //     final currency = '"${req.currency}"';
// //     final amount = req.amount;
// //     final secretKey = '"${widget.secretKey}"';
// //
// //     final html = """
// //     <!DOCTYPE html>
// //     <html lang="en">
// //     <head>
// //       <meta charset="UTF-8">
// //       <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
// //     </head>
// //     <body>
// //       <script src="https://web.alatpay.ng/js/alatpay.js"></script>
// //       <script>
// //         let popup = Alatpay.setup({
// //             apiKey: $apiKey,
// //             businessId: $businessId,
// //             secretKey: $secretKey,
// //             email: $email,
// //             phone: $phone,
// //             firstName: $firstName,
// //             lastName: $lastName,
// //             metaData: $metaData,
// //             currency: $currency,
// //             amount: $amount,
// //
// //             onTransaction: function (response) {
// //               AlatPayBridge.postMessage(JSON.stringify({
// //                 type: 'success',
// //                 data: response
// //               }));
// //             },
// //
// //             onClose: function () {
// //               AlatPayBridge.postMessage(JSON.stringify({
// //                 type: 'cancel'
// //               }));
// //             }
// //         });
// //
// //         function showPayment() { popup.show(); }
// //         showPayment();
// //       </script>
// //     </body>
// //     </html>
// //     """;
// //
// //     _controller = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       ..addJavaScriptChannel(
// //         'AlatPayBridge',
// //         onMessageReceived: (msg) {
// //           try {
// //             final decoded = jsonDecode(msg.message);
// //             if (decoded['type'] == 'success') {
// //               widget.onTransaction(decoded['data']);
// //             } else if (decoded['type'] == 'cancel') {
// //               widget.onClose?.call();
// //             }
// //           } catch (e) {
// //             debugPrint('⚠️ JS message decode error: $e');
// //           }
// //         },
// //       )
// //       ..setNavigationDelegate(
// //         NavigationDelegate(
// //           onPageStarted: (url) => debugPrint('🌍 Loading: $url'),
// //           onPageFinished: (url) {
// //             debugPrint('✅ Page loaded: $url');
// //             setState(() => _isLoaded = true);
// //           },
// //           onWebResourceError: (error) =>
// //               debugPrint('🚨 WebView error: ${error.description}'),
// //         ),
// //       )
// //       ..loadHtmlString(html);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           WebViewWidget(controller: _controller),
// //           if (!_isLoaded)
// //             const Center(child: CircularProgressIndicator()),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:alatpay_sdk/alatpay_sdk.dart';
//
// // class AlatPayCheckout extends StatefulWidget {
// //   final PaymentRequest request;
// //   final String apiKey;
// //   final Function(dynamic response)? onTransaction;
// //   final Function()? onClose;
// //
// //   const AlatPayCheckout({
// //     super.key,
// //     required this.request,
// //     required this.apiKey,
// //     this.onTransaction,
// //     this.onClose,
// //   });
// //
// //   @override
// //   State<AlatPayCheckout> createState() => _AlatPayCheckoutState();
// // }
// //
// // class _AlatPayCheckoutState extends State<AlatPayCheckout> {
// //   late WebViewXController webviewController;
// //   late String html;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     final r = widget.request;
// //
// //     // Safely encode metadata
// //     final metaData =
// //     r.customer.metadata == null ? 'null' : jsonEncode(r.customer.metadata);
// //
// //     // Build inline HTML to load AlatPay SDK
// //     html = """
// //     <!DOCTYPE html>
// //     <html lang="en">
// //     <head>
// //         <meta charset="UTF-8">
// //         <meta name="viewport"
// //               content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
// //     </head>
// //     <body>
// //       <script src="https://web.alatpay.ng/js/alatpay.js"></script>
// //       <script>
// //         let popup = Alatpay.setup({
// //           apiKey: "${widget.apiKey}",
// //           businessId: "${r.businessId}",
// //           email: "${r.customer.email}",
// //           phone: "${r.customer.phone ?? ''}",
// //           firstName: "${r.customer.firstName ?? ''}",
// //           lastName: "${r.customer.lastName ?? ''}",
// //           metadata: $metaData,
// //           currency: "${r.currency ?? 'NGN'}",
// //           amount: "${r.amount}",
// //
// //           onTransaction: function(response) {
// //             paymentsuccess(JSON.stringify(response));
// //           },
// //
// //           onClose: function() {
// //             paymentcancel("Payment cancelled");
// //           }
// //         });
// //
// //         popup.show();
// //       </script>
// //     </body>
// //     </html>
// //     """;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final media = MediaQuery.of(context).size;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Center(
// //         child: WebViewX(
// //           width: media.width,
// //           height: media.height,
// //           initialContent: html,
// //           initialSourceType: SourceType.html,
// //           onWebViewCreated: (controller) {
// //             webviewController = controller;
// //           },
// //           dartCallBacks: {
// //             // Transaction success from JS → Dart
// //             DartCallback(
// //               name: 'paymentsuccess',
// //               callBack: (message) {
// //                 debugPrint('💰 Payment success: $message');
// //                 try {
// //                   final response = jsonDecode(message);
// //                   widget.onTransaction?.call(response);
// //                 } catch (_) {
// //                   widget.onTransaction?.call(message);
// //                 }
// //               },
// //             ),
// //
// //             // Payment cancel from JS → Dart
// //             DartCallback(
// //               name: 'paymentcancel',
// //               callBack: (_) {
// //                 debugPrint('🚫 Payment cancelled');
// //                 if (widget.onClose != null) {
// //                   widget.onClose!();
// //                 } else {
// //                   Navigator.pop(context);
// //                 }
// //               },
// //             ),
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:webviewx2/webviewx2.dart';
// // import 'package:alatpay_sdk/alatpay_sdk.dart';
// //
// // class AlatPayCheckout extends StatefulWidget {
// //   final PaymentRequest request;
// //   final String secretKey;
// //   final Function(dynamic response)? onTransaction;
// //   final Function()? onClose;
// //
// //   const AlatPayCheckout({
// //     super.key,
// //     required this.request,
// //     required this.secretKey,
// //     this.onTransaction,
// //     this.onClose,
// //   });
// //
// //   @override
// //   State<AlatPayCheckout> createState() => _AlatPayCheckoutState();
// // }
// //
// // class _AlatPayCheckoutState extends State<AlatPayCheckout> {
// //   late WebViewXController webviewController;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final r = widget.request;
// //     final size = MediaQuery.of(context).size;
// //
// //     final checkoutUrl = Uri.https(
// //       'web.alatpay.ng',
// //       '/alatpay.js',
// //       {
// //         'apiKey': widget.secretKey,
// //         'businessId': r.businessId,
// //         'email': r.customer.email,
// //         'phone': r.customer.phone ?? '',
// //         'firstName': r.customer.firstName ?? '',
// //         'lastName': r.customer.lastName ?? '',
// //         'metadata': jsonEncode(r.customer.metadata ?? {}),
// //         'currency': r.currency ?? 'NGN',
// //         'amount': r.amount.toString(),
// //       },
// //     ).toString();
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: WebViewX(
// //           width: size.width,
// //           height: size.height,
// //           initialContent: checkoutUrl,
// //           initialSourceType: SourceType.url,
// //           javascriptMode: JavascriptMode.unrestricted,
// //           onWebViewCreated: (controller) {
// //             webviewController = controller;
// //             webviewController.loadContent(checkoutUrl, SourceType.url, headers: {
// //               "Content-Type": "application/json",
// //               "Ocp-Apim-Subscription-Key": widget.secretKey,
// //             });
// //
// //           },
// //           onPageStarted: (url) => debugPrint('🌍 Loading: $url'),
// //           onPageFinished: (url) => debugPrint('✅ Finished: $url'),
// //           dartCallBacks: {
// //             DartCallback(
// //               name: 'paymentsuccess',
// //               callBack: (message) {
// //                 debugPrint('💰 Payment success: $message');
// //                 try {
// //                   final data = jsonDecode(message);
// //                   widget.onTransaction?.call(data);
// //                 } catch (_) {
// //                   widget.onTransaction?.call(message);
// //                 }
// //               },
// //             ),
// //             DartCallback(
// //               name: 'paymentcancel',
// //               callBack: (_) {
// //                 debugPrint('🚫 Payment cancelled');
// //                 widget.onClose?.call() ?? Navigator.pop(context);
// //               },
// //             ),
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
