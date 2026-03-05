import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String paymentId;
  final Function(String transactionId) onPaymentComplete;
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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() async {
    // Initialize WebView controller first
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
            
            // Handle PayPal return URLs
            if (url.contains('/paypal/return') || url.contains('token=')) {
              // Extract token from URL if present
              final uri = Uri.parse(url);
              final token = uri.queryParameters['token'] ?? uri.queryParameters['PayerID'];
              if (token != null) {
                // Payment approved - extract order ID from URL or use token
                final orderId = uri.queryParameters['token'] ?? token;
                widget.onPaymentComplete(orderId);
              }
            } else if (url.contains('/paypal/cancel')) {
              widget.onPaymentCancelled();
            }
          },
          onWebResourceError: (WebResourceError error) {
            widget.onPaymentFailed('WebView-Fehler: ${error.description}');
          },
        ),
      );

    // Create PayPal order via backend
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      final orderData = await paymentService.createPayPalOrder(
        amount: widget.amount,
        currency: widget.currency,
        returnUrl: 'https://homedx.app/paypal/return',
        cancelUrl: 'https://homedx.app/paypal/cancel',
      );
      
      final approvalUrl = orderData['approvalUrl']!;
      
      // Load the real PayPal approval URL
      await _controller.loadRequest(Uri.parse(approvalUrl));
    } catch (e) {
      // Show error and allow user to go back
      if (mounted) {
        widget.onPaymentFailed('PayPal-Bestellung konnte nicht erstellt werden: $e');
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

