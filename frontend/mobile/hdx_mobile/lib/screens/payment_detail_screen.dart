import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../core/api_service.dart';
import '../services/payment_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/status_pill.dart';
import '../widgets/web/adaptive_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;
  final Map<String, dynamic>? initialPayment;

  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
    this.initialPayment,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  Map<String, dynamic>? _payment;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payment = widget.initialPayment;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _payment == null;
      _error = null;
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = PaymentService(api);
      final payment = await service.getPayment(widget.paymentId);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_payment == null) {
          _error = e.toString().replaceAll('Exception: ', '');
        }
        _loading = false;
      });
    }
  }

  static String _methodLabel(String method) {
    switch (method.toUpperCase()) {
      case 'CREDIT_CARD':
        return 'Kreditkarte';
      case 'PAYPAL':
        return 'PayPal';
      case 'BANK_TRANSFER':
        return 'Banküberweisung';
      case 'CRYPTO':
        return 'Krypto';
      default:
        return method.isEmpty ? 'Zahlung' : method;
    }
  }

  static String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Abgeschlossen';
      case 'PENDING':
        return 'Ausstehend';
      case 'FAILED':
        return 'Fehlgeschlagen';
      case 'REFUNDED':
        return 'Erstattet';
      case 'CANCELLED':
        return 'Storniert';
      default:
        return status.isEmpty ? 'Unbekannt' : status;
    }
  }

  static (Color, Color) _statusColors(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return (AppTheme.successColor, AppTheme.navy);
      case 'PENDING':
        return (AppTheme.primaryLight, AppTheme.primaryBlue);
      case 'FAILED':
      case 'CANCELLED':
        return (AppTheme.accentCoral.withValues(alpha: 0.55), AppTheme.navy);
      case 'REFUNDED':
        return (const Color(0xFFE8E0F5), const Color(0xFF5B4B8A));
      default:
        return (AppTheme.navy.withValues(alpha: 0.08), AppTheme.textColorSecondary);
    }
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  List<Map<String, dynamic>> _lineItems(Map<String, dynamic> payment) {
    final raw = payment['lineItems'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Zahlungsdetails',
      showWebHeader: false,
      onBack: () => context.canPop() ? context.pop() : context.go('/payments'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _payment == null
              ? FigmaEmptyState(
                  icon: Icons.error_outline,
                  title: 'Zahlung konnte nicht geladen werden',
                  message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                  actionLabel: 'Erneut versuchen',
                  onAction: _load,
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final payment = _payment!;
    final amount = payment['amount'];
    final currency = payment['currency']?.toString() ?? 'EUR';
    final status = payment['status']?.toString() ?? '';
    final method = payment['method']?.toString() ?? '';
    final description = payment['description']?.toString();
    final (badgeBg, badgeFg) = _statusColors(status);
    final amountLabel = amount is num
        ? '${amount.toStringAsFixed(2)} ${_currencySymbol(currency)}'
        : '$amount $currency';
    final items = _lineItems(payment);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        kIsWeb ? 24 : 8,
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        24,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeumorphicRaisedCard(
                height: null,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            amountLabel,
                            style: FigmaUi.rubik(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: _statusLabel(status),
                          background: badgeBg,
                          foreground: badgeFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _detailRow('Zahlungsmethode', _methodLabel(method)),
                    const SizedBox(height: 14),
                    _detailRow('Datum', _formatDate(payment['createdAt']?.toString())),
                    if (payment['completedAt'] != null) ...[
                      const SizedBox(height: 14),
                      _detailRow('Abgeschlossen', _formatDate(payment['completedAt']?.toString())),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _detailRow('Beschreibung', description),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Gekaufte Artikel',
                style: FigmaUi.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 14),
              if (items.isEmpty)
                NeumorphicRaisedCard(
                  height: null,
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    'Für diese Zahlung sind keine Artikeldetails gespeichert. '
                    'Bei neuen Käufen im Shop werden die Produkte hier angezeigt.',
                    style: FigmaUi.bodyLight(
                      fontSize: 17,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                )
              else
                ...items.map((item) {
                  final name = item['name']?.toString() ?? 'Artikel';
                  final qty = item['quantity'] is num ? (item['quantity'] as num).toInt() : 1;
                  final unit = item['unitPrice'] is num ? (item['unitPrice'] as num).toDouble() : 0.0;
                  final lineTotal = unit * qty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeumorphicRaisedCard(
                      height: null,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.sell_outlined, color: AppTheme.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: FigmaUi.rubik(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$qty × ${unit.toStringAsFixed(2)} ${_currencySymbol(currency)}',
                                  style: FigmaUi.rubik(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${lineTotal.toStringAsFixed(2)} ${_currencySymbol(currency)}',
                            style: FigmaUi.rubik(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              NeumorphicPillButton(
                label: 'Zurück zu Zahlungen',
                height: AppTheme.buttonHeightLarge,
                leadingIcon: Icons.arrow_back,
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textColor,
                onPressed: () => context.canPop() ? context.pop() : context.go('/payments'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FigmaUi.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.textColorSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: FigmaUi.rubik(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}
