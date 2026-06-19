/// Post-login destination based on user role.
String homeRouteForRole(String? role) {
  return role == 'DOCTOR' ? '/doctor/dashboard' : '/home';
}

/// Whether [location] is a public route that does not require authentication.
bool isPublicRoute(String location) {
  return location == '/' ||
      location == '/about' ||
      location == '/login' ||
      location == '/signup';
}
