import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/bluetooth_connection_screen.dart';
import '../screens/bluetooth_scan_screen.dart';
import '../screens/test_selection_screen.dart';
import '../screens/test_bluetooth_check_screen.dart';
import '../screens/doctor_selection_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/shop_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/login' || 
                              state.matchedLocation == '/signup';

        // If not logged in and trying to access protected route (including home), redirect to login
        if (!isLoggedIn && !isGoingToAuth) {
          return '/login';
        }

        // If logged in and trying to access auth routes, redirect to home
        if (isLoggedIn && isGoingToAuth) {
          return '/';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/bluetooth',
          name: 'bluetooth',
          builder: (context, state) => const BluetoothConnectionScreen(),
        ),
        GoRoute(
          path: '/bluetooth/scan',
          name: 'bluetooth-scan',
          builder: (context, state) => const BluetoothScanScreen(),
        ),
        GoRoute(
          path: '/tests',
          name: 'tests',
          builder: (context, state) => const TestSelectionScreen(),
        ),
        GoRoute(
          path: '/tests/:testTypeId/bluetooth-check',
          name: 'test-bluetooth-check',
          builder: (context, state) {
            final testTypeId = state.pathParameters['testTypeId'] ?? '';
            final testTypeName = state.uri.queryParameters['testTypeName'] ?? 'Test';
            return TestBluetoothCheckScreen(
              testTypeId: testTypeId,
              testTypeName: testTypeName,
            );
          },
        ),
        GoRoute(
          path: '/doctors',
          name: 'doctors',
          builder: (context, state) => const DoctorSelectionScreen(),
        ),
        GoRoute(
          path: '/doctors/:doctorId/appointment',
          name: 'appointment-booking',
          builder: (context, state) {
            final doctorId = state.pathParameters['doctorId'] ?? '';
            final doctorName = state.uri.queryParameters['doctorName'] ?? 'Arzt';
            final specialization = state.uri.queryParameters['specialization'] ?? '';
            return AppointmentBookingScreen(
              doctorId: doctorId,
              doctorName: doctorName,
              specialization: specialization,
            );
          },
        ),
        GoRoute(
          path: '/shop',
          name: 'shop',
          builder: (context, state) => const ShopScreen(),
        ),
      ],
    );
  }

}

