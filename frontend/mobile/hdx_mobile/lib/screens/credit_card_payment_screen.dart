import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/payment_service.dart';
import '../widgets/figma_ui.dart';

class CreditCardPaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String paymentId;
  final Future<void> Function() onPaymentComplete;
  final Function(String error) onPaymentFailed;

  const CreditCardPaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.paymentId,
    required this.onPaymentComplete,
    required this.onPaymentFailed,
  });

  @override
  State<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends State<CreditCardPaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final clientSecret = await paymentService.createStripePaymentIntent(
        paymentId: widget.paymentId,
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'HomeDX',
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      try {
        await paymentService.confirmStripePayment(paymentId: widget.paymentId);
      } catch (_) {
        await paymentService.waitForPaymentCompleted(widget.paymentId);
      }

      await widget.onPaymentComplete();
    } on stripe.StripeException catch (e) {
      String errorMessage = 'Zahlung fehlgeschlagen';
      if (e.error.code == stripe.FailureCode.Canceled) {
        errorMessage = 'Zahlung wurde abgebrochen';
      } else if (e.error.message != null) {
        errorMessage = e.error.message!;
      }
      widget.onPaymentFailed(errorMessage);
    } catch (e) {
      widget.onPaymentFailed('Zahlung fehlgeschlagen');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: const FigmaBackHeader(title: 'Kreditkartenzahlung'),
      bottomBar: FigmaBottomActionBar(
        buttonLabel: _isProcessing ? 'Wird verarbeitet…' : 'Bezahlen',
        loading: _isProcessing,
        onPressed: _isProcessing ? null : _processPayment,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Zu zahlender Betrag:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kartendaten werden sicher über Stripe eingegeben. Ihre App verarbeitet keine Kartennummern direkt.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
