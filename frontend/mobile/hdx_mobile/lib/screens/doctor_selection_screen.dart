import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../services/doctor_service.dart';
import '../utils/test_specialization_mapping.dart';
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

  List<String> get _availableLanguages {
    final languages = <String>{};
    for (final doctor in _doctors) {
      languages.addAll(doctor.languages);
    }
    final sorted = languages.toList();
    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

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
        children: [
          if (widget.testTypeId != null && widget.testTypeId!.isNotEmpty)
            _buildTestContextBanner(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.screenHorizontalPadding,
              16,
              AppTheme.screenHorizontalPadding,
              0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Arzt oder Fachrichtung suchen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_availableLanguages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenHorizontalPadding,
                16,
                AppTheme.screenHorizontalPadding,
                0,
              ),
              child: _LanguageFilterBar(
                languages: _availableLanguages,
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.medical_services_outlined,
              color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13)),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Fehler beim Laden',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loadDoctors,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_search,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Keine Ärzte gefunden',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Versuchen Sie eine andere Suche',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppTheme.screenHorizontalPadding,
              0,
              AppTheme.screenHorizontalPadding,
              24,
            ),
            child: _DoctorTileGrid(
              width: constraints.maxWidth,
              doctors: _filteredDoctors,
              onDoctorTap: _openDoctorBooking,
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
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        child: Column(
          children: [
            const Icon(
              Icons.person_outline,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 10),
            Text(
              doctor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FigmaUi.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialization,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FigmaUi.bodyLight(
                fontSize: 12,
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
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: FigmaUi.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 14,
              child: Text(
                doctor.languages.isNotEmpty ? doctor.languages.join(' · ') : '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FigmaUi.bodyLight(
                  fontSize: 11,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sprache',
          style: FigmaUi.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : AppTheme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected ? null : AppTheme.neumorphicRaised,
          ),
          child: Text(
            label,
            style: FigmaUi.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

