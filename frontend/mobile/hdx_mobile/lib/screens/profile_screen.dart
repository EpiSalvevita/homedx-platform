import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/user_service.dart' show UserData, UserService;
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../widgets/figma_ui.dart';

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
    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Profil',
        actions: [
          if (!_isLoading && _userData != null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textColor))
                  : const Icon(Icons.save_outlined, color: AppTheme.textColor),
              onPressed: _isSaving ? null : _saveUserData,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.screenHorizontalPadding, 8, AppTheme.screenHorizontalPadding, 0),
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
                              Text('Fehler beim Laden des Profils', style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              NeumorphicPillButton(label: 'Erneut versuchen', height: 52, onPressed: _loadUserData),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppTheme.neumorphicRaised,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
                                      child: const Icon(Icons.person_outline, size: 32, color: AppTheme.primaryBlue),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '${_userData?.firstName ?? ''} ${_userData?.lastName ?? ''}',
                                      style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_userData?.email ?? '', style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _firstNameController, label: 'Vorname', prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Vorname ist erforderlich' : null),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _lastNameController, label: 'Nachname', prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Nachname ist erforderlich' : null),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _emailController, label: 'E-mail', prefixIcon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || v.isEmpty) ? 'E-mail ist erforderlich' : null),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _phoneController, label: 'Handynummer', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _cityController, label: 'Stadt', prefixIcon: Icons.location_city_outlined),
                              const SizedBox(height: 20),
                              NeumorphicInsetField(controller: _countryController, label: 'Land', prefixIcon: Icons.public),
                              const SizedBox(height: 24),
                              NeumorphicPillButton(label: 'Änderungen speichern', loading: _isSaving, onPressed: _isSaving ? null : _saveUserData),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.neumorphicRaised,
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
}
