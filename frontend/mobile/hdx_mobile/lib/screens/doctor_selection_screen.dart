import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../services/doctor_service.dart';
import '../utils/test_specialization_mapping.dart';

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

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    return _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wählen Sie einen Arzt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Zurück',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.testTypeId != null && widget.testTypeId!.isNotEmpty)
              _buildTestContextBanner(context),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
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
            // Doctor List
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _filteredDoctors[index];
          return _buildDoctorCard(doctor);
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
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
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${doctor.reviewCount} Bewertungen)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (doctor.languages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: doctor.languages.map((lang) {
                          return Chip(
                            label: Text(
                              lang,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

