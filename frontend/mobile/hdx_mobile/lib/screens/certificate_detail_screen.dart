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
    final api = Provider.of<ApiService>(context, listen: false);
    final service = CertificateService(api);
    final bytes = await service.downloadPdfBytes(widget.certificateId);
    final file = File('/tmp/certificate-${widget.certificateId}.pdf');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF gespeichert: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Zertifikat',
        blueTopBar: true,
        onBack: () => context.pop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _certificate == null
                  ? const Center(child: Text('Nicht gefunden'))
                  : Padding(
                      padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _certificate!.certificateNumber,
                            style: FigmaUi.rubik(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Status: ${_certificate!.status}'),
                          Text('Test: ${_certificate!.testTypeId ?? '—'}'),
                          Text('Ergebnis: ${_certificate!.testResult ?? '—'}'),
                          Text(
                            'Gültig bis: ${_certificate!.validUntil.toLocal().toString().split(' ').first}',
                          ),
                          const SizedBox(height: 24),
                          if (!kIsWeb)
                            NeumorphicPillButton(
                              label: 'PDF teilen',
                              height: 48,
                              onPressed: _downloadPdf,
                            ),
                        ],
                      ),
                    ),
    );
  }
}
