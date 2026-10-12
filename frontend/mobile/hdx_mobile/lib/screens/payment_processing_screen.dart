import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../l10n/l10n_ext.dart';
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
                  title: context.l10n.paySuccess,
                  subtitle: context.l10n.orderConfirmed,
                ),
              ),
              (route) => route.isFirst,
            );
          },
          onPaymentFailed: (error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.paymentFailedWith(error.toString())),
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
                  title: context.l10n.paypalSuccess,
                  subtitle: context.l10n.orderConfirmed,
                ),
              ),
              (route) => route.isFirst,
            );
          },
          onPaymentCancelled: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.paypalCancelled),
                backgroundColor: Colors.orange,
              ),
            );
          },
          onPaymentFailed: (error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.paypalFailedWith(error.toString())),
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
                  title: context.l10n.sepaStarted,
                  subtitle: context.l10n.sepaStartedSubtitle,
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
