import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/login' || 
                              state.matchedLocation == '/signup';

        // If not logged in and trying to access protected route, redirect to login
        if (!isLoggedIn && !isGoingToAuth && state.matchedLocation != '/') {
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
      ],
    );
  }

}

