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
      testAccount: json['testaccount'] == true,
      authorized: json['authorized']?.toString() ?? 'accepted',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'dob': dateOfBirth,
      'city': city,
      'country': country,
      'phone': phone,
      'address1': address1,
      'postcode': postcode,
    };
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
        body: userData.toJson(),
      );

      if (response['success'] != true) {
        throw ApiException(
          response['error']?.toString() ?? 'Failed to update user data',
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
}

