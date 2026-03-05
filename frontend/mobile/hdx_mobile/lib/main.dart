import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/graphql_service.dart';
import 'services/payment_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Stripe with publishable key
  final stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripePublishableKey != null && stripePublishableKey.isNotEmpty) {
    stripe.Stripe.publishableKey = stripePublishableKey;
    // Optional: Set Stripe merchant identifier for Apple Pay
    // stripe.Stripe.merchantIdentifier = 'merchant.com.yourapp';
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final graphQLService = GraphQLService(apiService);
    final paymentService = PaymentService(graphQLService);
    final authProvider = AuthProvider(authService);
    final bluetoothProvider = BluetoothProvider();
    final cartProvider = CartProvider();

    // Initialize auth state
    authProvider.initialize();

    // Update GraphQL service when auth token changes
    // The token is already set in ApiService, GraphQLService reads it from there
    // We just need to reinitialize the client when auth state changes
    authProvider.addListener(() {
      graphQLService.updateAuthToken(apiService.authToken);
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: bluetoothProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<GraphQLService>.value(value: graphQLService),
        Provider<PaymentService>.value(value: paymentService),
      ],
      child: Builder(
        builder: (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return MaterialApp.router(
            title: 'HomeDX Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(auth),
            locale: const Locale('de', 'DE'),
            supportedLocales: const [
              Locale('de', 'DE'), // German
              Locale('en', 'US'), // English (fallback)
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
