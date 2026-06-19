import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

Future<void> initStripe() async {
  final stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripePublishableKey != null && stripePublishableKey.isNotEmpty) {
    stripe.Stripe.publishableKey = stripePublishableKey;
  }
}
