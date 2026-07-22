import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/user_service.dart' show UserData, UserService;
import '../core/api_service.dart';
import '../features/cube/cube_service.dart';
import '../utils/gender_labels.dart';
import '../utils/profile_errors.dart';
import '../utils/profile_field_metrics.dart';
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
  String? _selectedGenderLabel;

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

  Future<void> _loadUserData({bool showPageLoader = true}) async {
    if (showPageLoader) {
      setState(() { _isLoading = true; _error = null; });
    }
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _userService = UserService(apiService);
      final userData = await _userService.getUserData();
      if (!mounted) return;
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
        _selectedGenderLabel = genderApiToLabel(userData.gender);
        if (showPageLoader) _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        if (showPageLoader) _isLoading = false;
      });
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
        gender: labelToGenderApi(_selectedGenderLabel),
        dateOfBirth: _userData!.dateOfBirth,
        testAccount: _userData!.testAccount,
        authorized: _userData!.authorized,
      );

      await _userService.updateUserData(updatedData);
      if (mounted) {
        await _loadUserData(showPageLoader: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil gespeichert'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = localizeProfileError(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $message'), backgroundColor: AppTheme.errorColor),
        );
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
              Text(
                'Fehler beim Laden des Profils',
                style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              NeumorphicPillButton(
                label: 'Erneut versuchen',
                height: AppTheme.buttonHeightLarge,
                expanded: false,
                onPressed: _loadUserData,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = kIsWeb ? 32.0 : AppTheme.screenHorizontalPadding;
        final top = AppTheme.profilePageTopPadding;
        final bottom = AppTheme.profilePageBottomPadding;
        final minContentHeight = constraints.maxHeight - top - bottom;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minContentHeight.clamp(0.0, double.infinity)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: kIsWeb ? _buildWebForm() : _buildMobileForm(),
                ),
              ],
            ),
          ),
        );
      },
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
            style: FigmaUi.rubik(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.textColor),
          ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            email,
            style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
          ),
        ],
      ],
    );
  }

  Widget _profileField({
    required ProfileFieldMetrics metrics,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ProfileInsetField(
      metrics: metrics,
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _profileFieldSpacer(ProfileFieldMetrics metrics) =>
      SizedBox(height: metrics.rowSpacing);

  Widget _fieldRowSpacer(ProfileFieldMetrics metrics) => SizedBox(width: metrics.rowGap);

  Widget _firstNameField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _firstNameController,
        label: 'Vorname',
        icon: Icons.person_outline,
        validator: (v) => (v == null || v.isEmpty) ? 'Vorname ist erforderlich' : null,
      );

  Widget _lastNameField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _lastNameController,
        label: 'Nachname',
        icon: Icons.person_outline,
        validator: (v) => (v == null || v.isEmpty) ? 'Nachname ist erforderlich' : null,
      );

  Widget _emailField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _emailController,
        label: 'E-mail',
        icon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        validator: (v) => (v == null || v.isEmpty) ? 'E-mail ist erforderlich' : null,
      );

  Widget _phoneField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _phoneController,
        label: 'Handynummer',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      );

  Widget _addressField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _addressController,
        label: 'Adresse',
        icon: Icons.home_outlined,
      );

  Widget _postcodeField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _postcodeController,
        label: 'PLZ',
        icon: Icons.markunread_mailbox_outlined,
      );

  Widget _cityField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _cityController,
        label: 'Stadt',
        icon: Icons.location_city_outlined,
      );

  Widget _countryField(ProfileFieldMetrics metrics) => _profileField(
        metrics: metrics,
        controller: _countryController,
        label: 'Land',
        icon: Icons.public,
      );

  Widget _profileFieldPair({
    required bool pairedRows,
    required ProfileFieldMetrics metrics,
    required Widget left,
    required Widget right,
  }) {
    if (!pairedRows) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          left,
          _profileFieldSpacer(metrics),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        _fieldRowSpacer(metrics),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildProfileFields({
    required bool pairedRows,
    required ProfileFieldMetrics metrics,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _profileFieldPair(
          pairedRows: pairedRows,
          metrics: metrics,
          left: _firstNameField(metrics),
          right: _lastNameField(metrics),
        ),
        _profileFieldSpacer(metrics),
        _profileFieldPair(
          pairedRows: pairedRows,
          metrics: metrics,
          left: _emailField(metrics),
          right: _phoneField(metrics),
        ),
        _profileFieldSpacer(metrics),
        _profileFieldPair(
          pairedRows: pairedRows,
          metrics: metrics,
          left: _addressField(metrics),
          right: _postcodeField(metrics),
        ),
        _profileFieldSpacer(metrics),
        _profileFieldPair(
          pairedRows: pairedRows,
          metrics: metrics,
          left: _cityField(metrics),
          right: _countryField(metrics),
        ),
        _profileFieldSpacer(metrics),
        _buildGenderField(metrics),
      ],
    );
  }

  Widget _buildGenderField(ProfileFieldMetrics metrics) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: NeumorphicInsetDropdown(
          label: 'Geschlecht',
          prefixIcon: Icons.wc_outlined,
          value: _selectedGenderLabel,
          items: genderPickerLabels,
          isExpanded: false,
          validator: (value) =>
              value == null || value.isEmpty ? 'Bitte Geschlecht auswählen' : null,
          onChanged: (value) => setState(() => _selectedGenderLabel = value),
          fieldHeight: metrics.fieldHeight,
          fieldPadding: metrics.fieldPadding,
          fontSize: metrics.fontSize,
          labelFontSize: metrics.labelFontSize,
          labelOffsetLeft: metrics.labelOffsetLeft,
          labelOffsetTop: metrics.labelOffsetTop,
          iconSize: metrics.iconSize,
          contentGap: metrics.contentGap,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: NeumorphicPillButton(
        label: _isSaving ? 'Speichern…' : 'Änderungen speichern',
        leadingIcon: _isSaving ? null : Icons.save_outlined,
        height: AppTheme.buttonHeightLarge,
        expanded: false,
        loading: _isSaving,
        backgroundColor: AppTheme.accentMint,
        foregroundColor: AppTheme.onMint,
        onPressed: _isSaving ? null : _saveUserData,
      ),
    );
  }

  Widget _buildMobileForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = ProfileFieldMetrics.fromWidth(constraints.maxWidth);
        final pairedRows = constraints.maxWidth >= 480;

        return Column(
          children: [
            if (!kIsWeb) ...[
              _buildCubeSdkCard(),
              _profileFieldSpacer(metrics),
            ],
            _buildProfileSummary(),
            const SizedBox(height: 32),
            _buildProfileFields(pairedRows: pairedRows, metrics: metrics),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildWebForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formWidth = constraints.maxWidth.clamp(0.0, 800.0);
        final metrics = ProfileFieldMetrics.fromWidth(formWidth);
        final pairedRows = formWidth >= 640;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileSummary(),
                const SizedBox(height: 32),
                _buildProfileFields(pairedRows: pairedRows, metrics: metrics),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
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
