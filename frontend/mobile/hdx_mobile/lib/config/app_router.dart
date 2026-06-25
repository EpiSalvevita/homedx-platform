import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../screens/landing_screen.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/bluetooth_connection_screen.dart';
import '../screens/bluetooth_scan_screen.dart';
import '../screens/test_selection_screen.dart';
import '../screens/test_bluetooth_check_screen.dart';
import '../screens/cube_web_stub_screen.dart';
import '../screens/doctor_selection_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/appointments_list_screen.dart';
import '../screens/appointment_detail_screen.dart';
import '../screens/video_call_screen.dart';
import '../screens/doctor/doctor_dashboard_screen.dart';
import '../screens/doctor/doctor_appointments_screen.dart';
import '../screens/doctor/doctor_availability_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/test_results_screen.dart';
import '../screens/test_submission_screen.dart';
import '../screens/payments_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../models/product.dart';
import '../models/user_test_result.dart';
import '../services/cube_service.dart';
import '../screens/test_result_screen.dart';
import '../providers/auth_provider.dart';
import '../layout/web_app_shell.dart';
import 'auth_routes.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/login/doctor' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/signup/doctor' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/forgot-password/doctor' ||
            state.matchedLocation == '/reset-password';
        final role = authProvider.userRole;
        final isDoctor = role == 'DOCTOR';
        final location = state.matchedLocation;

        if (!isLoggedIn && !isPublicRoute(location)) {
          return '/login';
        }

        if (isLoggedIn && isGoingToAuth) {
          return homeRouteForRole(role);
        }

        if (isLoggedIn && location == '/') {
          return homeRouteForRole(role);
        }

        if (isLoggedIn && isDoctor) {
          if (location == '/home' ||
              location.startsWith('/doctors') ||
              location.startsWith('/appointments') ||
              location.startsWith('/tests') ||
              location.startsWith('/bluetooth') ||
              location == '/shop' ||
              location == '/results') {
            return '/doctor/dashboard';
          }
        }

        if (isLoggedIn && !isDoctor && location.startsWith('/doctor/')) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'landing',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/login/doctor',
          name: 'login-doctor',
          builder: (context, state) => const LoginScreen(isDoctor: true),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/signup/doctor',
          name: 'signup-doctor',
          builder: (context, state) => const SignupScreen(isDoctor: true),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/forgot-password/doctor',
          name: 'forgot-password-doctor',
          builder: (context, state) => const ForgotPasswordScreen(isDoctor: true),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          builder: (context, state) {
            final token = state.uri.queryParameters['token'];
            return ResetPasswordScreen(token: token);
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            if (kIsWeb) {
              return WebAppShell(child: child);
            }
            return child;
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/bluetooth',
              name: 'bluetooth',
              builder: (context, state) => const BluetoothConnectionScreen(),
            ),
        GoRoute(
          path: '/bluetooth/scan',
          name: 'bluetooth-scan',
          builder: (context, state) => kIsWeb
              ? const CubeWebStubScreen(title: 'Bluetooth-Scan')
              : const BluetoothScanScreen(),
        ),
        GoRoute(
          path: '/tests',
          name: 'tests',
          builder: (context, state) => kIsWeb
              ? const CubeWebStubScreen(title: 'Tests')
              : const TestSelectionScreen(),
        ),
        GoRoute(
          path: '/tests/:testTypeId/bluetooth-check',
          name: 'test-bluetooth-check',
          builder: (context, state) {
            if (kIsWeb) {
              return const CubeWebStubScreen(title: 'Test vorbereiten');
            }
            final testTypeId = state.pathParameters['testTypeId'] ?? '';
            final testTypeName =
                state.uri.queryParameters['testTypeName'] ?? 'Test';
            final rapidTestId = state.uri.queryParameters['rapidTestId'];
            return TestBluetoothCheckScreen(
              testTypeId: testTypeId,
              testTypeName: testTypeName,
              rapidTestId: rapidTestId,
            );
          },
        ),
        GoRoute(
          path: '/tests/:testTypeId/submission',
          name: 'test-submission',
          builder: (context, state) {
            if (kIsWeb) {
              return const CubeWebStubScreen(title: 'Test einreichen');
            }
            final testTypeId = state.pathParameters['testTypeId'] ?? '';
            final testTypeName =
                state.uri.queryParameters['testTypeName'] ?? 'Test';
            final rapidTestId = state.uri.queryParameters['rapidTestId'] ?? '';
            return TestSubmissionScreen(
              testTypeId: testTypeId,
              testTypeName: testTypeName,
              rapidTestId: rapidTestId,
              cubeResult: state.uri.queryParameters['cubeResult'],
            );
          },
        ),
        GoRoute(
          path: '/doctors',
          name: 'doctors',
          builder: (context, state) {
            final testTypeId = state.uri.queryParameters['testTypeId'];
            final testTypeName = state.uri.queryParameters['testTypeName'];
            return DoctorSelectionScreen(
              testTypeId: testTypeId,
              testTypeName: testTypeName,
            );
          },
        ),
        GoRoute(
          path: '/doctors/:doctorId/appointment',
          name: 'appointment-booking',
          builder: (context, state) {
            final doctorId = state.pathParameters['doctorId'] ?? '';
            final doctorName =
                state.uri.queryParameters['doctorName'] ?? 'Arzt';
            final specialization =
                state.uri.queryParameters['specialization'] ?? '';
            final testTypeId = state.uri.queryParameters['testTypeId'];
            final testTypeName = state.uri.queryParameters['testTypeName'];
            return AppointmentBookingScreen(
              doctorId: doctorId,
              doctorName: doctorName,
              specialization: specialization,
              testTypeId: testTypeId,
              testTypeName: testTypeName,
            );
          },
        ),
        GoRoute(
          path: '/appointments',
          name: 'appointments',
          builder: (context, state) => const AppointmentsListScreen(),
        ),
        GoRoute(
          path: '/appointments/:appointmentId',
          name: 'appointment-detail',
          builder: (context, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return AppointmentDetailScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/appointments/:appointmentId/call',
          name: 'appointment-call',
          builder: (context, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return VideoCallScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/doctor/dashboard',
          name: 'doctor-dashboard',
          builder: (context, state) => const DoctorDashboardScreen(),
        ),
        GoRoute(
          path: '/doctor/appointments',
          name: 'doctor-appointments',
          builder: (context, state) => const DoctorAppointmentsScreen(),
        ),
        GoRoute(
          path: '/doctor/availability',
          name: 'doctor-availability',
          builder: (context, state) => const DoctorAvailabilityScreen(),
        ),
        GoRoute(
          path: '/doctor/appointments/:appointmentId',
          name: 'doctor-appointment-detail',
          builder: (context, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return AppointmentDetailScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/doctor/appointments/:appointmentId/call',
          name: 'doctor-appointment-call',
          builder: (context, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return VideoCallScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/shop',
          name: 'shop',
          builder: (context, state) => const ShopScreen(),
          routes: [
            GoRoute(
              path: 'cart',
              name: 'shop-cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: 'checkout',
              name: 'shop-checkout',
              builder: (context, state) => const CheckoutScreen(),
            ),
            GoRoute(
              path: 'product',
              name: 'shop-product',
              builder: (context, state) {
                final product = state.extra as Product?;
                if (product == null) {
                  return const ShopScreen();
                }
                return ProductDetailsScreen(product: product);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/results',
          name: 'results',
          builder: (context, state) => const TestResultsScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              name: 'result-detail',
              builder: (context, state) {
                final item = state.extra as UserTestResult?;
                if (item == null) {
                  return const TestResultsScreen();
                }
                return TestResultScreen(
                  testTypeName: item.displayTestName,
                  testTypeId: item.testTypeId,
                  testDate: item.testDate,
                  result: CubeTestResult(
                    success: true,
                    testId: item.id,
                    result: item.result,
                    resultData: item.resultData
                        .map(CubeResultData.fromJson)
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/payments',
          name: 'payments',
          builder: (context, state) => const PaymentsHistoryScreen(),
        ),
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
