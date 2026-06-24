import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'credit_card_payment_screen.dart';
import 'paypal_payment_screen.dart';
import 'sepa_payment_screen.dart';
import 'order_success_screen.dart';

enum PaymentMethod {
  creditCard,
  paypal,
  sepa,
}

class PaymentProcessingScreen extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final double amount;
  final String currency;
  final String paymentId;

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

    switch (paymentMethod) {
      case PaymentMethod.creditCard:
        return CreditCardPaymentScreen(
          amount: amount,
          currency: currency,
          paymentId: paymentId,
          onPaymentComplete: () async {
            cartProvider.clear();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(
                  amount: amount,
                  currency: currency,
                  title: 'Zahlung erfolgreich',
                  subtitle: 'Ihre Bestellung wurde bestätigt. Sie erhalten eine Bestätigung in der App.',
                ),
              ),
              (route) => route.isFirst,
            );
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
          onPaymentComplete: () async {
            cartProvider.clear();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(
                  amount: amount,
                  currency: currency,
                  title: 'PayPal-Zahlung erfolgreich',
                  subtitle: 'Ihre Bestellung wurde bestätigt. Sie erhalten eine Bestätigung in der App.',
                ),
              ),
              (route) => route.isFirst,
            );
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
            cartProvider.clear();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(
                  amount: amount,
                  currency: currency,
                  title: 'SEPA-Überweisung gestartet',
                  subtitle: 'Bitte überweisen Sie den Betrag innerhalb von 3–5 Werktagen. '
                      'Ihre Bestellung bleibt bis dahin reserviert.',
                ),
              ),
              (route) => route.isFirst,
            );
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop();
          },
        );
    }
  }
}
