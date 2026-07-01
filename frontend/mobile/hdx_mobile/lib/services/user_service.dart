import 'api_service.dart' show ApiService, ApiException, UnauthorizedException;

class UserData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int? dateOfBirth;
  final String? city;
  final String? country;
  final String? phone;
  final String? address1;
  final String? postcode;
  final String? gender;
  final bool testAccount;
  final String authorized;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.dateOfBirth,
    this.city,
    this.country,
    this.phone,
    this.address1,
    this.postcode,
    this.gender,
    this.testAccount = false,
    this.authorized = 'accepted',
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      firstName: json['firstname']?.toString() ?? '',
      lastName: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dateOfBirth: json['dob'] is int ? json['dob'] : null,
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      phone: json['phone']?.toString(),
      address1: json['address1']?.toString(),
      postcode: json['postcode']?.toString(),
      gender: json['gender']?.toString(),
      testAccount: json['testaccount'] == true,
      authorized: json['authorized']?.toString() ?? 'accepted',
    );
  }


  bool _filled(String? value) => value != null && value.trim().isNotEmpty;

  /// True when all editable profile fields from the profile form are set.
  bool get isProfileComplete =>
      _filled(firstName) &&
      _filled(lastName) &&
      _filled(email) &&
      _filled(phone) &&
      _filled(address1) &&
      _filled(postcode) &&
      _filled(city) &&
      _filled(country) &&
      _filled(gender);

  /// Short hint for the home activity row when profile is incomplete.
  String get profileCompletionHint {
    if (isProfileComplete) return 'Ihre Profildaten sind hinterlegt';
    final missing = <String>[];
    if (!_filled(phone)) missing.add('Telefon');
    if (!_filled(address1)) missing.add('Adresse');
    if (!_filled(postcode)) missing.add('PLZ');
    if (!_filled(city)) missing.add('Stadt');
    if (!_filled(country)) missing.add('Land');
    if (!_filled(gender)) missing.add('Geschlecht');
    if (missing.isEmpty) {
      return 'Vervollständigen Sie Ihr Profil, um zu beginnen';
    }
    if (missing.length == 1) {
      return 'Noch ausstehend: ${missing.first}';
    }
    return 'Noch ausstehend: ${missing.take(2).join(', ')}${missing.length > 2 ? '…' : ''}';
  }

  Map<String, dynamic> toUpdateJson() {
    final payload = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
    };

    if (dateOfBirth != null) payload['dob'] = dateOfBirth;
    if (_filled(city)) payload['city'] = city!.trim();
    if (_filled(country)) payload['country'] = country!.trim();
    if (_filled(phone)) payload['phone'] = phone!.trim();
    if (_filled(address1)) payload['address1'] = address1!.trim();
    if (_filled(postcode)) payload['postcode'] = postcode!.trim();
    if (_filled(gender)) payload['gender'] = gender!.trim();

    return payload;
  }
}

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<UserData> getUserData() async {
    try {
      final response = await _apiService.post('/get-user-data');

      if (response['success'] == true && response['userdata'] != null) {
        return UserData.fromJson(response['userdata'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          response['error']?.toString() ?? 'Failed to get user data',
          0,
        );
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<void> updateUserData(UserData userData) async {
    try {
      final response = await _apiService.post(
        '/update-user-data',
        body: userData.toUpdateJson(),
      );

      if (response['success'] != true) {
        throw ApiException(
          _formatMobileError(response, 'Failed to update user data'),
          0,
        );
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  String _formatMobileError(Map<String, dynamic> response, String fallback) {
    final error = response['error']?.toString() ?? fallback;
    final validation = response['validation'];
    if (validation is List && validation.isNotEmpty) {
      return '$error: ${validation.map((e) => e.toString()).join('; ')}';
    }
    return error;
  }
}

