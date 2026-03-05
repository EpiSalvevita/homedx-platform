import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import 'credit_card_payment_screen.dart';
import 'paypal_payment_screen.dart';
import 'sepa_payment_screen.dart';

enum PaymentMethod {
  creditCard,
  paypal,
  sepa,
}

class PaymentProcessingScreen extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final double amount;
  final String currency;
  final String paymentId; // Payment ID from backend

  const PaymentProcessingScreen({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final paymentService = Provider.of<PaymentService>(context);

    switch (paymentMethod) {
      case PaymentMethod.creditCard:
        return CreditCardPaymentScreen(
          amount: amount,
          currency: currency,
          paymentId: paymentId,
          onPaymentComplete: (transactionId) async {
            // Update payment status to COMPLETED
            await _completePayment(context, paymentService, paymentId, transactionId);
            cartProvider.clear();
            Navigator.of(context).popUntil((route) => route.isFirst);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Zahlung erfolgreich abgeschlossen!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onPaymentFailed: (error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Zahlung fehlgeschlagen: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      case PaymentMethod.paypal:
        return PayPalPaymentScreen(
          amount: amount,
          currency: currency,
          paymentId: paymentId,
          onPaymentComplete: (transactionId) async {
            // Update payment status to COMPLETED
            await _completePayment(context, paymentService, paymentId, transactionId);
            cartProvider.clear();
            Navigator.of(context).popUntil((route) => route.isFirst);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PayPal-Zahlung erfolgreich abgeschlossen!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PayPal-Zahlung abgebrochen'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          onPaymentFailed: (error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PayPal-Zahlung fehlgeschlagen: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      case PaymentMethod.sepa:
        return SEPAPaymentScreen(
          amount: amount,
          currency: currency,
          paymentId: paymentId,
          onPaymentComplete: () async {
            // SEPA payments are marked as PENDING (awaiting bank transfer)
            cartProvider.clear();
            Navigator.of(context).popUntil((route) => route.isFirst);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SEPA-Überweisung initiiert. Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen.'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 6),
                ),
              );
            }
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop();
          },
        );
    }
  }

  Future<void> _completePayment(
    BuildContext context,
    PaymentService paymentService,
    String paymentId,
    String transactionId,
  ) async {
    try {
      // Update payment with transaction ID and status
      await paymentService.updatePayment(
        paymentId: paymentId,
        transactionId: transactionId,
        status: 'COMPLETED',
      );

      print('Payment updated successfully: $paymentId');
    } catch (e) {
      print('Error updating payment: $e');
      // Don't show error to user as payment was already processed
    }
  }
}

