import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final authProvider = AuthProvider(authService);
    final bluetoothProvider = BluetoothProvider();

    // Initialize auth state
    authProvider.initialize();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: bluetoothProvider),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
      ],
      child: Builder(
        builder: (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return MaterialApp.router(
            title: 'HomeDX Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(auth),
          );
        },
      ),
    );
  }
}
