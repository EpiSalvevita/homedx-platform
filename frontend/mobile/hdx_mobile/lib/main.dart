import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/stripe_init.dart';
import 'config/push_init.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';
import 'services/notification_service.dart';
import 'providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await dotenv.load(fileName: '.env');

  if (!kIsWeb) {
    await initStripe();
  }

  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  final apiService = ApiService();
  final authService = AuthService(apiService);
  final paymentService = PaymentService(apiService);
  final notificationService = NotificationService(apiService);
  final notificationProvider = NotificationProvider(notificationService);
  final authProvider = AuthProvider(authService);
  final bluetoothProvider = BluetoothProvider();
  final cartProvider = CartProvider();

  apiService.onUnauthorized = () {
    authProvider.logout();
  };

  await authProvider.initialize();

  if (!kIsWeb && authProvider.isAuthenticated) {
    await initPush(notificationService);
  }

  runApp(
    MyApp(
      localeProvider: localeProvider,
      authProvider: authProvider,
      bluetoothProvider: bluetoothProvider,
      cartProvider: cartProvider,
      apiService: apiService,
      authService: authService,
      paymentService: paymentService,
      notificationProvider: notificationProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final LocaleProvider localeProvider;
  final AuthProvider authProvider;
  final BluetoothProvider bluetoothProvider;
  final CartProvider cartProvider;
  final ApiService apiService;
  final AuthService authService;
  final PaymentService paymentService;
  final NotificationProvider notificationProvider;

  const MyApp({
    super.key,
    required this.localeProvider,
    required this.authProvider,
    required this.bluetoothProvider,
    required this.cartProvider,
    required this.apiService,
    required this.authService,
    required this.paymentService,
    required this.notificationProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(widget.authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider.value(value: widget.bluetoothProvider),
        ChangeNotifierProvider.value(value: widget.cartProvider),
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider.value(value: widget.notificationProvider),
        Provider<ApiService>.value(value: widget.apiService),
        Provider<AuthService>.value(value: widget.authService),
        Provider<PaymentService>.value(value: widget.paymentService),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleProvider>().locale;
          return MaterialApp.router(
            title: 'HomeDX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _router,
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
