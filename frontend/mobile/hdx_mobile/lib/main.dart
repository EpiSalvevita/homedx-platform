import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/stripe_init.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/graphql_service.dart';
import 'services/payment_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  if (!kIsWeb) {
    await initStripe();
  }

  final localeProvider = LocaleProvider();
  await localeProvider.initialize();
  
  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const MyApp({super.key, required this.localeProvider});

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
        ChangeNotifierProvider.value(value: localeProvider),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<GraphQLService>.value(value: graphQLService),
        Provider<PaymentService>.value(value: paymentService),
      ],
      child: Builder(
        builder: (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final locale = context.watch<LocaleProvider>().locale;
          return MaterialApp.router(
            title: 'HomeDX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(auth),
            locale: locale,
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
