import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/certificate.dart';
import '../services/api_service.dart';
import '../services/certificate_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/status_pill.dart';
import '../widgets/web/adaptive_screen.dart';
import 'certificates_list_screen.dart' show certificateStatusLabel, certificateStatusColors, certificateTypeLabel;

class CertificateDetailScreen extends StatefulWidget {
  final String certificateId;

  const CertificateDetailScreen({super.key, required this.certificateId});

  @override
  State<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  Certificate? _certificate;
  bool _loading = true;
  String? _error;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = CertificateService(api);
      final cert = await service.getCertificate(widget.certificateId);
      if (!mounted) return;
      setState(() {
        _certificate = cert;
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

  Future<void> _downloadPdf() async {
    if (kIsWeb) return;
    setState(() => _downloading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = CertificateService(api);
      final bytes = await service.downloadPdfBytes(widget.certificateId);
      final file = File('/tmp/certificate-${widget.certificateId}.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gespeichert: ${file.path}'), backgroundColor: AppTheme.successColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Zertifikat',
      showWebHeader: false,
      onBack: () => context.canPop() ? context.pop() : context.go('/certificates'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: FigmaUi.rubik(color: AppTheme.textColor)),
                  ),
                )
              : _certificate == null
                  ? Center(
                      child: Text('Zertifikat nicht gefunden', style: FigmaUi.rubik(color: AppTheme.textColor)),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        kIsWeb ? 24 : 8,
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDetailCard(_certificate!),
                          const SizedBox(height: 24),
                          if (!kIsWeb)
                            NeumorphicPillButton(
                              label: _downloading ? 'Wird geladen…' : 'PDF teilen',
                              leadingIcon: _downloading ? null : Icons.picture_as_pdf_outlined,
                              loading: _downloading,
                              onPressed: _downloading ? null : _downloadPdf,
                            )
                          else
                            FigmaListCard(
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                              ),
                              title: 'PDF-Download',
                              subtitle: 'Öffnen Sie die HomeDX-App auf Ihrem Smartphone, um dieses Zertifikat als PDF zu teilen.',
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailCard(Certificate certificate) {
    final (badgeBg, badgeFg) = certificateStatusColors(certificate.status);
    final labelStyle = FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary);
    final bodyStyle = FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColor);

    return NeumorphicRaisedCard(
      height: null,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.verified_outlined, color: AppTheme.primaryBlue, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificateTypeLabel(certificate.type),
                      style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                    ),
                    const SizedBox(height: 6),
                    Text(certificate.certificateNumber, style: labelStyle),
                  ],
                ),
              ),
              StatusPill(
                label: certificateStatusLabel(certificate.status),
                background: badgeBg,
                foreground: badgeFg,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x1A142543)),
          const SizedBox(height: 16),
          if (certificate.testResult != null) ...[
            Text('Ergebnis', style: labelStyle),
            const SizedBox(height: 4),
            Text(certificate.testResult!, style: bodyStyle),
            const SizedBox(height: 14),
          ],
          Text('Gültigkeit', style: labelStyle),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event_available_outlined, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(certificate.validFrom)} – ${_formatDate(certificate.validUntil)}',
                style: bodyStyle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Ausgestellt am', style: labelStyle),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(_formatDate(certificate.issuedAt), style: bodyStyle),
            ],
          ),
        ],
      ),
    );
  }
}
