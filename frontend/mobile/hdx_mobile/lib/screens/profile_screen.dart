import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/user_service.dart' show UserData, UserService;
import '../services/api_service.dart';
import '../services/cube_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserService _userService;
  UserData? _userData;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  /// Native Cube SDK: bundled `cube_license.dat` accepted by the library.
  bool? _cubeLicenseValid;
  String _cubeSdkVersion = '';
  bool _cubeSdkInfoLoading = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCubeSdkInfo();
  }

  Future<void> _loadCubeSdkInfo() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final cube = CubeService(api);
      final valid = await cube.licenseValid();
      final version = await cube.getVersion();
      if (!mounted) return;
      setState(() {
        _cubeLicenseValid = valid;
        _cubeSdkVersion = version;
        _cubeSdkInfoLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cubeLicenseValid = false;
        _cubeSdkInfoLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _userService = UserService(apiService);
      final userData = await _userService.getUserData();
      setState(() {
        _userData = userData;
        _firstNameController.text = userData.firstName;
        _lastNameController.text = userData.lastName;
        _emailController.text = userData.email;
        _phoneController.text = userData.phone ?? '';
        _cityController.text = userData.city ?? '';
        _countryController.text = userData.country ?? '';
        _addressController.text = userData.address1 ?? '';
        _postcodeController.text = userData.postcode ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate() || _userData == null) return;
    setState(() { _isSaving = true; _error = null; });

    try {
      final updatedData = UserData(
        id: _userData!.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        address1: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        postcode: _postcodeController.text.trim().isEmpty ? null : _postcodeController.text.trim(),
        dateOfBirth: _userData!.dateOfBirth,
        testAccount: _userData!.testAccount,
        authorized: _userData!.authorized,
      );

      await _userService.updateUserData(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil aktualisiert'), backgroundColor: AppTheme.successColor));
        await _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: AppTheme.errorColor));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_isLoading && _userData != null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveUserData,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildCubeSdkCard(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _userData == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Fehler beim Laden des Profils', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _loadUserData, child: const Text('Erneut versuchen')),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                        // Avatar card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_outline, size: 36, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${_userData?.firstName ?? ''} ${_userData?.lastName ?? ''}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(_userData?.email ?? '', style: TextStyle(fontSize: 14, color: AppTheme.textColorSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildField(_firstNameController, 'Vorname', Icons.person_outline, required: true),
                        const SizedBox(height: 14),
                        _buildField(_lastNameController, 'Nachname', Icons.person_outline, required: true),
                        const SizedBox(height: 14),
                        _buildField(_emailController, 'E-mail', Icons.email_outlined, required: true, keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _buildField(_phoneController, 'Handynummer', Icons.phone_outlined, keyboard: TextInputType.phone),
                        const SizedBox(height: 14),
                        _buildField(_cityController, 'Stadt', Icons.location_city_outlined),
                        const SizedBox(height: 14),
                        _buildField(_countryController, 'Land', Icons.public),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveUserData,
                            child: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Änderungen speichern'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCubeSdkCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: _cubeSdkInfoLoading
          ? const Row(
              children: [
                SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Cube-SDK wird geprüft…'),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cube-Gerät (SDK)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 8),
                Text(
                  _cubeSdkVersion.isEmpty ? 'Version: —' : 'Version: $_cubeSdkVersion',
                  style: TextStyle(fontSize: 14, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _cubeLicenseValid == true ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 20,
                      color: _cubeLicenseValid == true ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _cubeLicenseValid == true
                            ? 'Bundled-Lizenz: gültig (laut SDK)'
                            : 'Bundled-Lizenz: ungültig oder abgelaufen — neue cube_license.dat vom Anbieter einspielen und App neu bauen.',
                        style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool required = false, TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$label ist erforderlich' : null
          : null,
    );
  }
}
