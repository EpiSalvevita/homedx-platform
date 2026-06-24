import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import '../widgets/web/adaptive_screen.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  State<PaymentsHistoryScreen> createState() => _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends State<PaymentsHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _payments = [];

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
      final service = PaymentService(api);
      final payments = await service.getUserPayments('');
      if (!mounted) return;
      setState(() {
        _payments = payments;
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
      title: 'Zahlungen',
      blueTopBar: true,
      onBack: () => context.go('/profile'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _payments.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Keine Zahlungen')),
                          ],
                        )
                      : ListView.separated(
                          itemCount: _payments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _payments[index];
                            final amount = p['amount'];
                            final currency = p['currency'] ?? 'EUR';
                            final status = p['status'] ?? '';
                            final method = p['method'] ?? '';
                            final created = p['createdAt']?.toString() ?? '';
                            return ListTile(
                              title: Text('$amount $currency'),
                              subtitle: Text('$method · $status\n$created'),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
    );
  }
}
