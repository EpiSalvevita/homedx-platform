import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/certificate.dart';
import '../services/api_service.dart';
import '../services/certificate_service.dart';
import '../widgets/figma_ui.dart';

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
    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Zertifikate',
        blueTopBar: true,
        onBack: () => context.go('/home'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Keine Zertifikate vorhanden')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final c = _items[index];
                            return ListTile(
                              title: Text(c.certificateNumber),
                              subtitle: Text(
                                '${c.testTypeId ?? 'Test'} · ${c.testResult ?? c.status}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/certificates/${c.id}'),
                            );
                          },
                        ),
                ),
    );
  }
}
