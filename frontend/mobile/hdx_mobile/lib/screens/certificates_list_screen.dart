import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/certificate.dart';
import '../core/api_service.dart';
import '../services/certificate_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/status_pill.dart';
import '../widgets/web/adaptive_screen.dart';

String certificateStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'ISSUED':
      return 'Ausgestellt';
    case 'DRAFT':
      return 'Entwurf';
    case 'EXPIRED':
      return 'Abgelaufen';
    case 'REVOKED':
      return 'Widerrufen';
    default:
      return status.isEmpty ? 'Unbekannt' : status;
  }
}

(Color, Color) certificateStatusColors(String status) {
  switch (status.toUpperCase()) {
    case 'ISSUED':
      return (AppTheme.successColor, AppTheme.navy);
    case 'DRAFT':
      return (AppTheme.primaryLight, AppTheme.primaryBlue);
    case 'REVOKED':
      return (AppTheme.accentCoral.withValues(alpha: 0.55), AppTheme.navy);
    case 'EXPIRED':
      return (AppTheme.navy.withValues(alpha: 0.08), AppTheme.textColorSecondary);
    default:
      return (AppTheme.navy.withValues(alpha: 0.08), AppTheme.textColorSecondary);
  }
}

String certificateTypeLabel(String type) {
  switch (type.toUpperCase()) {
    case 'TEST_RESULT':
      return 'Testergebnis';
    case 'VACCINATION':
      return 'Impfung';
    case 'RECOVERY':
      return 'Genesung';
    case 'MEDICAL_CLEARANCE':
      return 'Ärztliche Freigabe';
    default:
      return type.isEmpty ? 'Zertifikat' : type;
  }
}

class CertificatesListScreen extends StatefulWidget {
  const CertificatesListScreen({super.key});

  @override
  State<CertificatesListScreen> createState() => _CertificatesListScreenState();
}

class _CertificatesListScreenState extends State<CertificatesListScreen> {
  bool _loading = true;
  String? _error;
  List<Certificate> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = CertificateService(api);
      final items = await service.listCertificates();
      if (!mounted) return;
      setState(() {
        _items = items;
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
    return AdaptiveScreen(
      title: 'Zertifikate',
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 24 : 8,
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            24,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Tippen Sie auf ein Zertifikat für Details.',
              style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
              )
            else if (_error != null)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.error_outline, color: AppTheme.errorColor),
                ),
                title: 'Zertifikate konnten nicht geladen werden',
                subtitle: _error!,
              )
            else if (_items.isEmpty)
              const FigmaEmptyState(
                icon: Icons.verified_outlined,
                title: 'Noch keine Zertifikate',
                message: 'Zertifikate erscheinen hier nach einem abgeschlossenen Test.',
              )
            else
              ..._items.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                    child: _CertificateCard(
                      certificate: c,
                      onTap: () => context.push('/certificates/${c.id}'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const _CertificateCard({required this.certificate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg) = certificateStatusColors(certificate.status);
    final hasTestInfo = certificate.testTypeId != null || certificate.testResult != null;
    final testInfo = hasTestInfo
        ? '${certificate.testTypeId ?? 'Test'} · ${certificate.testResult ?? certificate.status}'
        : null;

    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_outlined, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.certificateNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  testInfo ?? certificateTypeLabel(certificate.type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusPill(
            label: certificateStatusLabel(certificate.status),
            background: badgeBg,
            foreground: badgeFg,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textColorSecondary),
        ],
      ),
    );
  }
}
