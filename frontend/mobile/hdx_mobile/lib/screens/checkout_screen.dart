import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/figma_ui.dart';
import 'payment_processing_screen.dart' show PaymentMethod, PaymentProcessingScreen;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;

  String _methodName(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.creditCard: return 'Kreditkarte';
      case PaymentMethod.paypal: return 'PayPal';
      case PaymentMethod.sepa: return 'SEPA-Überweisung';
    }
  }

  String _methodBackend(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.creditCard: return 'CREDIT_CARD';
      case PaymentMethod.paypal: return 'PAYPAL';
      case PaymentMethod.sepa: return 'BANK_TRANSFER';
    }
  }

  IconData _methodIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.creditCard: return Icons.credit_card;
      case PaymentMethod.paypal: return Icons.account_balance_wallet;
      case PaymentMethod.sepa: return Icons.account_balance;
    }
  }

  Future<void> _processPayment(CartProvider cartProvider, AuthProvider authProvider, PaymentService paymentService) async {
    if (cartProvider.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final userId = authProvider.userId;
      if (userId == null || userId.isEmpty) throw Exception('Benutzer nicht angemeldet.');

      final totalAmount = cartProvider.totalPrice;
      if (totalAmount <= 0) throw Exception('Ungültiger Betrag');

      final payment = await paymentService.createPayment(
        userId: userId,
        paymentMethod: _methodBackend(_selectedPaymentMethod),
      );

      final paymentAmount = (payment['amount'] as num?)?.toDouble() ?? totalAmount;

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentProcessingScreen(
              paymentMethod: _selectedPaymentMethod,
              amount: paymentAmount,
              currency: payment['currency']?.toString() ?? 'EUR',
              paymentId: payment['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zahlung fehlgeschlagen: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentService = Provider.of<PaymentService>(context);

    return FigmaScreen(
      header: const FigmaBackHeader(title: 'Kasse'),
      bottomBar: cartProvider.isEmpty
          ? null
          : FigmaBottomActionBar(
              buttonLabel: _isProcessing ? 'Wird verarbeitet…' : 'Jetzt zahlen',
              loading: _isProcessing,
              onPressed: _isProcessing ? null : () => _processPayment(cartProvider, authProvider, paymentService),
            ),
      body: cartProvider.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.textColorSecondary),
                  const SizedBox(height: 16),
                  const Text('Ihr Warenkorb ist leer'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FigmaSectionTitle('Bestellübersicht'),
                  const SizedBox(height: 12),

                  // Order items
                  ...cartProvider.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.neumorphicRaised,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.local_offer, color: AppTheme.primaryBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('${item.product.name} ${item.quantity > 1 ? "x${item.quantity}" : ""}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                        ),
                        Text('${item.totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  )),

                  // Total
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.neumorphicRaised,
                    ),
                    child: Row(
                      children: [
                        const Text('Gesamt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                        const Spacer(),
                        Text('${cartProvider.totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const FigmaSectionTitle('Zahlungsmethode'),
                  const SizedBox(height: 12),

                  // Payment methods
                  ...PaymentMethod.values.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = method),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.textColorSecondary, width: 2),
                              ),
                              child: isSelected
                                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle)))
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Icon(_methodIcon(method), color: AppTheme.primaryBlue, size: 22),
                            const SizedBox(width: 12),
                            Text(_methodName(method), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
