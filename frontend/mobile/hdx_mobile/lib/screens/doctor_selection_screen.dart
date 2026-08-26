import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../core/api_service.dart';
import '../services/doctor_service.dart';
import '../utils/app_assets.dart';
import '../utils/test_specialization_mapping.dart';
import '../utils/doctor_languages.dart';
import '../widgets/doctor_portrait_avatar.dart';
import '../widgets/figma_ui.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web/adaptive_screen.dart';

class DoctorSelectionScreen extends StatefulWidget {
  /// When set, the doctor list is pre-filtered to specialists matching the
  /// originating test (e.g. positive RheumaCheck -> Rheumatologie). The
  /// [testTypeName] is the human-readable label used in the banner.
  final String? testTypeId;
  final String? testTypeName;

  const DoctorSelectionScreen({
    super.key,
    this.testTypeId,
    this.testTypeName,
  });

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedLanguage;
  bool _fellBackToFullList = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final doctorService = DoctorService(api);
      final doctors = await doctorService.getAvailableDoctors(
        testTypeId: widget.testTypeId,
      );

      // Detect whether the service fell back to the full list because no
      // specialist matched, so we can show an honest banner.
      bool fellBack = false;
      final id = widget.testTypeId;
      if (id != null && id.isNotEmpty) {
        final filtered = DoctorService.filterDoctorsForTestType(doctors, id);
        fellBack = filtered.length != doctors.length;
      }

      if (mounted) {
        setState(() {
          _doctors = doctors;
          _isLoading = false;
          _fellBackToFullList = fellBack;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _filterLanguages => DoctorLanguages.supported;

  List<Doctor> get _filteredDoctors {
    return _doctors.where((doctor) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      if (_selectedLanguage != null) {
        final lang = _selectedLanguage!.toLowerCase();
        final speaksLanguage = doctor.languages.any(
          (l) => l.toLowerCase() == lang,
        );
        if (!speaksLanguage) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Wählen Sie einen Arzt',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.testTypeId != null && widget.testTypeId!.isNotEmpty)
            _buildTestContextBanner(context),
          Padding(
            padding: EdgeInsets.fromLTRB(
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              16,
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              0,
            ),
            child: TextField(
              style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: 'Arzt oder Fachrichtung suchen…',
                hintStyle: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
                prefixIcon: const Icon(Icons.search, size: 24, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  borderSide: BorderSide(color: AppTheme.navy.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_filterLanguages.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                20,
                kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                24,
              ),
              child: _LanguageFilterBar(
                languages: _filterLanguages,
                selectedLanguage: _selectedLanguage,
                onSelected: (language) {
                  setState(() => _selectedLanguage = language);
                },
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTestContextBanner(BuildContext context) {
    final specialization =
        TestSpecializationMapping.primarySpecialization(widget.testTypeId);
    final testName = widget.testTypeName?.trim().isNotEmpty == true
        ? widget.testTypeName!
        : 'Ihren Test';

    final headline = _fellBackToFullList
        ? 'Kein passender Facharzt verfügbar'
        : 'Empfohlene Fachärzte: $specialization';
    final body = _fellBackToFullList
        ? 'Für $testName konnten wir aktuell keinen Facharzt für $specialization finden. Wir zeigen Ihnen alle verfügbaren Ärzte.'
        : 'Basierend auf Ihrem positiven $testName empfehlen wir Ärzte mit Fachrichtung $specialization.';

    return Container(
      key: const Key('doctor-selection-test-banner'),
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        16,
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        0,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_services_outlined, size: 28, color: AppTheme.primaryBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: FigmaUi.rubik(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return FigmaEmptyState(
        icon: Icons.error_outline,
        title: 'Ärzte konnten nicht geladen werden',
        message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
        actionLabel: 'Erneut versuchen',
        onAction: _loadDoctors,
      );
    }

    if (_filteredDoctors.isEmpty) {
      return const FigmaEmptyState(
        assetPath: AppAssets.doctorExplaining,
        icon: Icons.person_search,
        title: 'Keine Ärzte gefunden',
        message: 'Versuchen Sie eine andere Suche oder Sprache.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              8,
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              24,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _DoctorTileGrid(
                  width: contentWidth.clamp(0.0, 1100.0),
                  doctors: _filteredDoctors,
                  onDoctorTap: _openDoctorBooking,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openDoctorBooking(Doctor doctor) {
    final testTypeQuery = (widget.testTypeId?.isNotEmpty == true)
        ? '&testTypeId=${Uri.encodeComponent(widget.testTypeId!)}'
            '${widget.testTypeName?.isNotEmpty == true ? '&testTypeName=${Uri.encodeComponent(widget.testTypeName!)}' : ''}'
        : '';
    context.push(
      '/doctors/${doctor.id}/appointment'
      '?doctorName=${Uri.encodeComponent(doctor.name)}'
      '&specialization=${Uri.encodeComponent(doctor.specialization)}'
      '$testTypeQuery',
    );
  }
}

class _DoctorTileGrid extends StatelessWidget {
  final double width;
  final List<Doctor> doctors;
  final ValueChanged<Doctor> onDoctorTap;

  const _DoctorTileGrid({
    required this.width,
    required this.doctors,
    required this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.quickActionGridSpacing;
    final aspectRatio = AppTheme.doctorSelectionCardAspectRatio;
    final crossAxisCount = AppBreakpoints.layoutGridCrossAxisCount(
      width,
      spacing: spacing,
      minTileWidth: 200,
      maxColumns: 4,
    );
    final tileWidth = (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
    final tileHeight = tileWidth / aspectRatio;

    final rows = <List<Doctor>>[];
    for (var i = 0; i < doctors.length; i += crossAxisCount) {
      final end = i + crossAxisCount > doctors.length ? doctors.length : i + crossAxisCount;
      rows.add(doctors.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: spacing),
          _DoctorTileRow(
            spacing: spacing,
            tileHeight: tileHeight,
            slotCount: crossAxisCount,
            doctors: rows[r],
            onDoctorTap: onDoctorTap,
          ),
        ],
      ],
    );
  }
}

class _DoctorTileRow extends StatelessWidget {
  final double spacing;
  final double tileHeight;
  final int slotCount;
  final List<Doctor> doctors;
  final ValueChanged<Doctor> onDoctorTap;

  const _DoctorTileRow({
    required this.spacing,
    required this.tileHeight,
    required this.slotCount,
    required this.doctors,
    required this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tileHeight,
      child: Row(
        children: [
          for (var i = 0; i < slotCount; i++) ...[
            Expanded(
              child: i < doctors.length
                  ? _DoctorTile(
                      doctor: doctors[i],
                      onTap: () => onDoctorTap(doctors[i]),
                    )
                  : const SizedBox.shrink(),
            ),
            if (i < slotCount - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorTile({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FigmaRaisedTapCard(
      expandHeight: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        child: Column(
          children: [
            DoctorPortraitAvatar(
              doctorId: doctor.id,
              doctorName: doctor.name,
              imageUrl: doctor.imageUrl,
              size: 72,
            ),
            const SizedBox(height: 12),
            Text(
              doctor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FigmaUi.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              doctor.specialization,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FigmaUi.bodyLight(
                fontSize: 14,
                color: AppTheme.textColorSecondary,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFE8B84A),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: FigmaUi.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Text(
                doctor.languages.isNotEmpty ? doctor.languages.join(' · ') : '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FigmaUi.bodyLight(
                  fontSize: 13,
                  color: AppTheme.textColorSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageFilterBar extends StatelessWidget {
  final List<String> languages;
  final String? selectedLanguage;
  final ValueChanged<String?> onSelected;

  const _LanguageFilterBar({
    required this.languages,
    required this.selectedLanguage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sprache',
            style: FigmaUi.rubik(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                _LanguageFilterChip(
                  key: const ValueKey('doctor-lang-filter-all'),
                  label: 'Alle',
                  selected: selectedLanguage == null,
                  onTap: () => onSelected(null),
                ),
                for (final language in languages)
                  _LanguageFilterChip(
                    key: ValueKey('doctor-lang-filter-$language'),
                    label: language,
                    selected: selectedLanguage == language,
                    onTap: () => onSelected(language),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : AppTheme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected ? null : AppTheme.neumorphicRaised,
          ),
          child: Text(
            label,
            style: FigmaUi.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

