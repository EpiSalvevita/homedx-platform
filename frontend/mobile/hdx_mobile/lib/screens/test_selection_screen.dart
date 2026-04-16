import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../models/test_type.dart';
import '../services/test_service.dart';
import '../services/api_service.dart';


class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({super.key});

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  List<TestType> _testTypes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTestTypes();
  }

  Future<void> _loadTestTypes() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final testService = TestService(apiService);
      final testTypes = await testService.getTestTypes();
      if (mounted) setState(() { _testTypes = testTypes; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _selectTest(TestType testType) {
    context.push('/tests/${testType.id}/bluetooth-check?testTypeName=${Uri.encodeComponent(testType.name)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testtyp auswählen')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTestTypes,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Fehler beim Laden der Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadTestTypes, child: const Text('Erneut versuchen')),
            ],
          ),
        ),
      );
    }

    if (_testTypes.isEmpty) {
      return const Center(child: Text('Keine Tests verfügbar', style: TextStyle(fontSize: 16)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _testTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildTestCard(_testTypes[index]),
    );
  }

  Widget _buildTestCard(TestType testType) {
    return GestureDetector(
      onTap: () => _selectTest(testType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.science, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(testType.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  if (testType.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(testType.description, style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textColorSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}
