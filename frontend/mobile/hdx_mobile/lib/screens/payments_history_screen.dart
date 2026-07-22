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
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      body: RefreshIndicator(
        onRefresh: _load,
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
                      'Übersicht Ihrer Zahlungen und Bestellungen.',
                      style: FigmaUi.bodyLight(
                        fontSize: 17,
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      FigmaEmptyState(
                        icon: Icons.error_outline,
                        title: 'Zahlungen konnten nicht geladen werden',
                        message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                        actionLabel: 'Erneut versuchen',
                        onAction: _load,
                      )
                    else if (_payments.isEmpty)
                      const FigmaEmptyState(
                        icon: Icons.payment_outlined,
                        title: 'Noch keine Zahlungen',
                        message: 'Abgeschlossene Zahlungen erscheinen hier.',
                      )
                    else
                      ..._payments.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                          child: _PaymentCard(
                            payment: p,
                            onTap: () {
                              final id = p['id']?.toString();
                              if (id == null || id.isEmpty) return;
                              context.push('/payments/$id', extra: p);
                            },
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

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onTap;

  const _PaymentCard({required this.payment, required this.onTap});

  static IconData _iconForMethod(String method) {
    switch (method.toUpperCase()) {
      case 'CREDIT_CARD':
        return Icons.credit_card;
      case 'PAYPAL':
        return Icons.account_balance_wallet_outlined;
      case 'BANK_TRANSFER':
        return Icons.account_balance_outlined;
      case 'CRYPTO':
        return Icons.currency_bitcoin;
      default:
        return Icons.payment_outlined;
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
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date  $time';
  }

  @override
  Widget build(BuildContext context) {
    final amount = payment['amount'];
    final currency = payment['currency']?.toString() ?? 'EUR';
    final status = payment['status']?.toString() ?? '';
    final method = payment['method']?.toString() ?? '';
    final created = _formatDate(payment['createdAt']?.toString());
    final description = payment['description']?.toString();
    final amountLabel = amount is num
        ? '${amount.toStringAsFixed(2)} ${_currencySymbol(currency)}'
        : '$amount $currency';
    final (badgeBg, badgeFg) = _statusColors(status);
    final title = description?.isNotEmpty == true ? description! : _methodLabel(method);

    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconForMethod(method), color: AppTheme.primaryBlue, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FigmaUi.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _methodLabel(method),
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
                if (created.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    created,
                    style: FigmaUi.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountLabel,
                style: FigmaUi.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              StatusPill(
                label: _statusLabel(status),
                background: badgeBg,
                foreground: badgeFg,
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textColorSecondary),
        ],
      ),
    );
  }

  String _currencySymbol(String currency) {
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
}
