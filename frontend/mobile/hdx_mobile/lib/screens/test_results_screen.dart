import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/neumorphic.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({super.key});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  bool _isLoading = true;
  List<_TestResultItem> _results = const [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final items = <_TestResultItem>[
      _TestResultItem(testName: 'RheumaCheck', resultLabel: 'Negativ', isPositive: false, dateTime: now.subtract(const Duration(days: 1, hours: 2))),
      _TestResultItem(testName: 'Vitamin D', resultLabel: 'Positiv', isPositive: true, dateTime: now.subtract(const Duration(days: 7, hours: 5))),
      _TestResultItem(testName: 'RheumaCheck', resultLabel: 'Negativ', isPositive: false, dateTime: now.subtract(const Duration(days: 14, hours: 3))),
    ];

    if (!mounted) return;
    setState(() { _results = items; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testergebnisse')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadResults,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tippen Sie auf einen Eintrag für Details.',
                        style: TextStyle(fontSize: 14, color: AppTheme.textColorSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_results.isEmpty)
                NeumorphicContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: AppTheme.textColorSecondary),
                      const SizedBox(height: 12),
                      Text('Noch keine Testergebnisse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
                    ],
                  ),
                )
              else
                ..._results.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResultCard(item: item),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestResultItem {
  final String testName;
  final String resultLabel;
  final bool isPositive;
  final DateTime? dateTime;

  const _TestResultItem({required this.testName, required this.resultLabel, required this.isPositive, required this.dateTime});
}

class _ResultCard extends StatelessWidget {
  final _TestResultItem item;
  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final badgeColor = item.isPositive ? AppTheme.errorColor : AppTheme.primaryBlue;
    final iconColor = item.isPositive ? AppTheme.errorColor : AppTheme.successColor;
    final dateStr = item.dateTime != null
        ? '${item.dateTime!.day.toString().padLeft(2, '0')}.${item.dateTime!.month.toString().padLeft(2, '0')}.${item.dateTime!.year}'
        : '';
    final timeStr = item.dateTime != null
        ? '${item.dateTime!.hour.toString().padLeft(2, '0')}:${item.dateTime!.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isPositive ? Icons.error_outline : Icons.check_circle_outline,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.testName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.resultLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(dateStr, style: TextStyle(fontSize: 13, color: AppTheme.primaryBlue)),
              const Spacer(),
              Text(timeStr, style: TextStyle(fontSize: 13, color: AppTheme.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }
}
