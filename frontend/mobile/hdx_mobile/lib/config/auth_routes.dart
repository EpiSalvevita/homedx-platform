/// Post-login destination based on user role.
String homeRouteForRole(String? role) {
  return role == 'DOCTOR' ? '/doctor/dashboard' : '/home';
}

/// Whether [location] is a public route that does not require authentication.
bool isPublicRoute(String location) {
  return location == '/' ||
      location == '/about' ||
      location.startsWith('/legal/') ||
      location == '/login' ||
      location == '/login/doctor' ||
      location == '/signup' ||
      location == '/signup/doctor' ||
      location == '/signup/confirmation' ||
      location == '/signup/doctor/confirmation' ||
      location == '/forgot-password' ||
      location == '/forgot-password/doctor' ||
      location == '/reset-password';
}
