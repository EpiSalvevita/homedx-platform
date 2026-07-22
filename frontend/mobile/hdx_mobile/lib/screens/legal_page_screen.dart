import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/legal_page.dart';
import '../core/api_service.dart';
import '../services/legal_page_service.dart';
import '../widgets/figma_ui.dart';

/// Displays a single legal document (Terms, Privacy Policy, Impressum,
/// Cookie Policy) fetched from the backend `LegalPage` content.
///
/// Added so the consent checkbox on [TestSubmissionScreen] can link to
/// real content instead of referencing non-interactive placeholder text
/// (see docs/regulatory/gap-assessment.md §6).
class LegalPageScreen extends StatefulWidget {
  final String type;

  const LegalPageScreen({super.key, required this.type});

  @override
  State<LegalPageScreen> createState() => _LegalPageScreenState();
}

class _LegalPageScreenState extends State<LegalPageScreen> {
  LegalPage? _page;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = LegalPageService(api);
      final page = await service.getLegalPage(widget.type);
      if (!mounted) return;
      setState(() {
        _page = page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: FigmaBackHeader(
        title: _page?.title ?? 'Rechtliches',
        blueTopBar: true,
        onBack: () => context.pop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                  child: Text(
                    _page?.content ?? '',
                    style: FigmaUi.rubik(color: AppTheme.textColor, fontSize: 14),
                  ),
                ),
    );
  }
}
