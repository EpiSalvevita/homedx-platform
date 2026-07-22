import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/user_test_result.dart';
import '../core/api_service.dart';
import '../services/test_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';
import '../widgets/test_result_badge.dart';

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
    context.push(
      '/results/detail',
      extra: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Testergebnisse',
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      body: RefreshIndicator(
        onRefresh: _loadResults,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 24 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            24,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tippen Sie auf einen Eintrag für Details.',
                      style: FigmaUi.bodyLight(
                        fontSize: 17,
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      FigmaEmptyState(
                        icon: Icons.error_outline,
                        title: 'Ergebnisse konnten nicht geladen werden',
                        message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                        actionLabel: 'Erneut versuchen',
                        onAction: _loadResults,
                      )
                    else if (_results.isEmpty)
                      FigmaEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Noch keine Testergebnisse',
                        message: kIsWeb
                            ? 'Ergebnisse erscheinen hier nach einem Test in der Android-App.'
                            : 'Starten Sie einen Test, um Ergebnisse zu sehen.',
                      )
                    else
                      ..._results.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                          child: _ResultCard(
                            item: item,
                            onTap: () => _openResultDetail(item),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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

    final kind = item.resultKind;

    // Hug content: fixed testResultCardHeight (136) is 1px short once date row +
    // divider + 22px padding are laid out (common yellow/black overflow stripe).
    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  TestResultBadge.iconForKind(kind),
                  color: TestResultBadge.iconColorForKind(kind),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.displayTestName,
                  style: FigmaUi.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TestResultBadge(result: item, showIcon: false),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppTheme.textColorSecondary,
              ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0x1A142543)),
            ),
            Row(
              children: [
                Text(
                  dateStr,
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  timeStr,
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
