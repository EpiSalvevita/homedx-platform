import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/payment_service.dart';
import '../widgets/figma_ui.dart';
import '../l10n/l10n_ext.dart';

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
    final l10n = context.l10n;
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
      String errorMessage = l10n.payFailed;
      if (e.error.code == stripe.FailureCode.Canceled) {
        errorMessage = l10n.payCancelled;
      } else if (e.error.message != null) {
        errorMessage = e.error.message!;
      }
      widget.onPaymentFailed(errorMessage);
    } catch (e) {
      widget.onPaymentFailed(l10n.payFailed);
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
      header: FigmaBackHeader(title: context.l10n.cardPaymentTitle),
      bottomBar: FigmaBottomActionBar(
        buttonLabel: _isProcessing ? context.l10n.processing : context.l10n.payButton,
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
                    Text(
                      context.l10n.amountDue,
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
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentBlue),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.cardStripeNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.navy,
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
