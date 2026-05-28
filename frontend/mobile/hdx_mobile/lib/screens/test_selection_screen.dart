import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../models/test_type.dart';
import '../services/test_service.dart';
import '../services/api_service.dart';
import '../widgets/figma_ui.dart';

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
    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Testtyp auswählen',
        blueTopBar: true,
        onBack: () => context.go('/'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTestTypes,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        children: const [SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text('Fehler beim Laden der Tests', textAlign: TextAlign.center, style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
          const SizedBox(height: 24),
          Center(child: NeumorphicPillButton(label: 'Erneut versuchen', height: 52, onPressed: _loadTestTypes)),
        ],
      );
    }

    if (_testTypes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        children: [
          const SizedBox(height: 80),
          Center(child: Text('Keine Tests verfügbar', style: FigmaUi.rubik(fontSize: 16, color: AppTheme.textColor))),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
      itemCount: _testTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.testTypeCardSpacing),
      itemBuilder: (context, index) => _buildTestCard(_testTypes[index]),
    );
  }

  Widget _buildTestCard(TestType testType) {
    final description = testType.description.isNotEmpty
        ? testType.description
        : 'Rheumatoid arthritis screening test';

    return NeumorphicRaisedCard(
      height: AppTheme.testTypeCardHeight,
      padding: AppTheme.testTypeCardPadding,
      onTap: () => _selectTest(testType),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  testType.name,
                  style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: FigmaUi.bodyLight(),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textColorSecondary),
        ],
      ),
    );
  }
}
