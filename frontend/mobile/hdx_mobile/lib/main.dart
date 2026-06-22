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
import 'services/payment_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  if (!kIsWeb) {
    await initStripe();
  }

  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  final apiService = ApiService();
  final authService = AuthService(apiService);
  final paymentService = PaymentService(apiService);
  final authProvider = AuthProvider(authService);
  final bluetoothProvider = BluetoothProvider();
  final cartProvider = CartProvider();

  apiService.onUnauthorized = () {
    authProvider.logout();
  };

  await authProvider.initialize();

  runApp(
    MyApp(
      localeProvider: localeProvider,
      authProvider: authProvider,
      bluetoothProvider: bluetoothProvider,
      cartProvider: cartProvider,
      apiService: apiService,
      authService: authService,
      paymentService: paymentService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final AuthProvider authProvider;
  final BluetoothProvider bluetoothProvider;
  final CartProvider cartProvider;
  final ApiService apiService;
  final AuthService authService;
  final PaymentService paymentService;

  const MyApp({
    super.key,
    required this.localeProvider,
    required this.authProvider,
    required this.bluetoothProvider,
    required this.cartProvider,
    required this.apiService,
    required this.authService,
    required this.paymentService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: bluetoothProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
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
              Locale('de', 'DE'),
              Locale('en', 'US'),
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
