import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/user_service.dart' show UserData, UserService;
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

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
    if (!kIsWeb) {
      _loadCubeSdkInfo();
    } else {
      _cubeSdkInfoLoading = false;
    }
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
    return AdaptiveScreen(
      title: 'Profil',
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      actions: [
        if (!_isLoading && _userData != null)
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textColor))
                : const Icon(Icons.save_outlined, color: AppTheme.textColor),
            onPressed: _isSaving ? null : _saveUserData,
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _userData == null) {
      return Center(
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
      );
    }

    return SingleChildScrollView(
      padding: kIsWeb ? const EdgeInsets.fromLTRB(24, 0, 24, 24) : const EdgeInsets.all(AppTheme.screenHorizontalPadding),
      child: Form(
        key: _formKey,
        child: kIsWeb ? _buildWebForm() : _buildMobileForm(),
      ),
    );
  }

  Widget _buildProfileSummary() {
    final name = '${_userData?.firstName ?? ''} ${_userData?.lastName ?? ''}'.trim();
    final email = _userData?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(
            name,
            style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
          ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary),
          ),
        ],
      ],
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ProfileInsetField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _profileFieldSpacer() => const SizedBox(height: AppTheme.infoInsetCardSpacing);

  Widget _buildSaveTile() {
    return FigmaInsetInfoCard(
      icon: Icons.save_outlined,
      title: 'Änderungen speichern',
      trailing: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
            )
          : null,
      onTap: _isSaving ? null : _saveUserData,
    );
  }

  Widget _buildMobileForm() {
    return Column(
      children: [
        if (!kIsWeb) ...[
          _buildCubeSdkCard(),
          _profileFieldSpacer(),
        ],
        _buildProfileSummary(),
        _profileFieldSpacer(),
        _profileField(
          controller: _firstNameController,
          label: 'Vorname',
          icon: Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? 'Vorname ist erforderlich' : null,
        ),
        _profileFieldSpacer(),
        _profileField(
          controller: _lastNameController,
          label: 'Nachname',
          icon: Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? 'Nachname ist erforderlich' : null,
        ),
        _profileFieldSpacer(),
        _profileField(
          controller: _emailController,
          label: 'E-mail',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v == null || v.isEmpty) ? 'E-mail ist erforderlich' : null,
        ),
        _profileFieldSpacer(),
        _profileField(
          controller: _phoneController,
          label: 'Handynummer',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _profileFieldSpacer(),
        _profileField(controller: _cityController, label: 'Stadt', icon: Icons.location_city_outlined),
        _profileFieldSpacer(),
        _profileField(controller: _countryController, label: 'Land', icon: Icons.public),
        const SizedBox(height: 16),
        FigmaInsetInfoCard(
          icon: Icons.payment_outlined,
          title: 'Zahlungsverlauf',
          subtitle: 'Zahlungen und Belege anzeigen',
          onTap: () => context.push('/payments'),
        ),
        _profileFieldSpacer(),
        _buildSaveTile(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWebForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 640;
        Widget field(Widget w) => Padding(padding: const EdgeInsets.only(bottom: AppTheme.infoInsetCardSpacing), child: w);

        final left = Column(
          children: [
            field(_profileField(
              controller: _firstNameController,
              label: 'Vorname',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Vorname ist erforderlich' : null,
            )),
            field(_profileField(
              controller: _lastNameController,
              label: 'Nachname',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Nachname ist erforderlich' : null,
            )),
            field(_profileField(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'E-mail ist erforderlich' : null,
            )),
            field(_profileField(
              controller: _phoneController,
              label: 'Handynummer',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            )),
          ],
        );

        final right = Column(
          children: [
            field(_profileField(controller: _cityController, label: 'Stadt', icon: Icons.location_city_outlined)),
            field(_profileField(controller: _countryController, label: 'Land', icon: Icons.public)),
            field(_profileField(controller: _addressController, label: 'Adresse', icon: Icons.home_outlined)),
            field(_profileField(controller: _postcodeController, label: 'PLZ', icon: Icons.markunread_mailbox_outlined)),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSummary(),
            const SizedBox(height: AppTheme.infoInsetCardSpacing),
            if (twoCol)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 24),
                  Expanded(child: right),
                ],
              )
            else
              Column(children: [left, right]),
            const SizedBox(height: 8),
            FigmaInsetInfoCard(
              icon: Icons.payment_outlined,
              title: 'Zahlungsverlauf',
              subtitle: 'Zahlungen und Belege anzeigen',
              onTap: () => context.push('/payments'),
            ),
            const SizedBox(height: AppTheme.infoInsetCardSpacing),
            _buildSaveTile(),
          ],
        );
      },
    );
  }

  Widget _buildCubeSdkCard() {
    if (_cubeSdkInfoLoading) {
      return const FigmaInsetInfoCard(
        icon: Icons.bluetooth_searching,
        title: 'Cube-Gerät (SDK)',
        subtitle: 'Cube-SDK wird geprüft…',
      );
    }

    final licenseValid = _cubeLicenseValid == true;
    return FigmaInsetInfoCard(
      height: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cube-Gerät (SDK)',
            style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor),
          ),
          const SizedBox(height: 4),
          Text(
            _cubeSdkVersion.isEmpty ? 'Version: —' : 'Version: $_cubeSdkVersion',
            style: FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                licenseValid ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 18,
                color: licenseValid ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  licenseValid
                      ? 'Bundled-Lizenz: gültig (laut SDK)'
                      : 'Bundled-Lizenz: ungültig oder abgelaufen — neue cube_license.dat vom Anbieter einspielen und App neu bauen.',
                  style: FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
