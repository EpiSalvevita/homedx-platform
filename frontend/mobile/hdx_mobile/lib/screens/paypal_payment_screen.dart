import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String paymentId;
  final Future<void> Function() onPaymentComplete;
  final Function() onPaymentCancelled;
  final Function(String error) onPaymentFailed;

  const PayPalPaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.paymentId,
    required this.onPaymentComplete,
    required this.onPaymentCancelled,
    required this.onPaymentFailed,
  });

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handledReturn = false;
  String? _paypalOrderId;

  static const _paypalHosts = ['paypal.com', 'paypalobjects.com'];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  bool _isPayPalHost(String host) {
    final lower = host.toLowerCase();
    return _paypalHosts.any((h) => lower == h || lower.endsWith('.$h'));
  }

  bool _isReturnUrl(String url) {
    return url.contains('paypal/return') || url.contains('/paypal/return');
  }

  bool _isCancelUrl(String url) {
    return url.contains('paypal/cancel') || url.contains('/paypal/cancel');
  }

  Future<void> _handlePayPalReturn() async {
    if (_handledReturn) return;
    _handledReturn = true;

    final paymentService = Provider.of<PaymentService>(context, listen: false);
    try {
      await paymentService.capturePayPalOrder(
        paymentId: widget.paymentId,
        paypalOrderId: _paypalOrderId,
      );
      await widget.onPaymentComplete();
    } catch (_) {
      try {
        await paymentService.waitForPaymentCompleted(widget.paymentId);
        await widget.onPaymentComplete();
      } catch (e) {
        widget.onPaymentFailed('PayPal-Zahlung konnte nicht bestätigt werden');
      }
    }
  }

  void _initializeWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }

            if (_isCancelUrl(request.url)) {
              widget.onPaymentCancelled();
              return NavigationDecision.prevent;
            }

            if (_isReturnUrl(request.url)) {
              _handlePayPalReturn();
              return NavigationDecision.prevent;
            }

            if (!_isPayPalHost(uri.host)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            widget.onPaymentFailed('WebView-Fehler: ${error.description}');
          },
        ),
      );

    final paymentService = Provider.of<PaymentService>(context, listen: false);

    try {
      final orderData = await paymentService.createPayPalOrder(
        paymentId: widget.paymentId,
        returnUrl: 'https://homedx.app/paypal/return',
        cancelUrl: 'https://homedx.app/paypal/cancel',
      );

      _paypalOrderId = orderData['orderId'];
      final approvalUrl = orderData['approvalUrl']!;

      await _controller.loadRequest(Uri.parse(approvalUrl));
    } catch (e) {
      if (mounted) {
        widget.onPaymentFailed('PayPal-Bestellung konnte nicht erstellt werden');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal-Zahlung'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentCancelled();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
