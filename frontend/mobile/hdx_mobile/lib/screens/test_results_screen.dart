import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/user_test_result.dart';
import '../services/api_service.dart';
import '../services/cube_service.dart';
import '../services/test_service.dart';
import '../widgets/figma_ui.dart';
import 'test_result_screen.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({super.key});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  bool _isLoading = true;
  String? _error;
  List<UserTestResult> _results = const [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final testService = TestService(apiService);
      final results = await testService.getUserTestResults();
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _results = const [];
        _isLoading = false;
      });
    }
  }

  void _openResultDetail(UserTestResult item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestResultScreen(
          testTypeName: item.displayTestName,
          testTypeId: item.testTypeId,
          testDate: item.testDate,
          result: CubeTestResult(
            success: true,
            testId: item.id,
            result: item.result,
            resultData: item.resultData
                .map(CubeResultData.fromJson)
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: FigmaBackHeader(title: 'Testergebnisse', blueTopBar: true),
      body: RefreshIndicator(
        onRefresh: _loadResults,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const FigmaInfoBanner(message: 'Tippen Sie auf einen Eintrag für Details.'),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_error != null)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.error_outline, color: AppTheme.errorColor),
                ),
                title: 'Ergebnisse konnten nicht geladen werden',
                subtitle: _error!,
              )
            else if (_results.isEmpty)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.assignment_outlined, color: AppTheme.primaryBlue),
                ),
                title: 'Noch keine Testergebnisse',
                subtitle: 'Starten Sie einen Test, um Ergebnisse zu sehen.',
              )
            else
              ..._results.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                    child: _ResultCard(
                      item: item,
                      onTap: () => _openResultDetail(item),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final UserTestResult item;
  final VoidCallback onTap;

  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateTime = item.testDate;
    final dateStr = dateTime != null
        ? '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}'
        : '';
    final timeStr = dateTime != null
        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : '';

    return NeumorphicRaisedCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  item.isPositive ? Icons.error_outline : Icons.check_circle_outline,
                  color: item.isPositive ? AppTheme.errorColor : AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(item.displayTestName, style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              ),
              FigmaResultBadge(label: item.resultLabel, isPositive: item.isPositive),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textColorSecondary),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0x1A142543))),
            Row(
              children: [
                Text(dateStr, style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue)),
                const Spacer(),
                Text(timeStr, style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
