import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import '../providers/auth_provider.dart';
import 'payment_processing_screen.dart' show PaymentMethod, PaymentProcessingScreen;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Kreditkarte';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.sepa:
        return 'SEPA-Überweisung';
    }
  }

  String _getPaymentMethodBackendValue(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'CREDIT_CARD';
      case PaymentMethod.paypal:
        return 'PAYPAL';
      case PaymentMethod.sepa:
        return 'BANK_TRANSFER';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.sepa:
        return Icons.account_balance;
    }
  }

  Future<void> _processPayment(CartProvider cartProvider, AuthProvider authProvider, PaymentService paymentService) async {
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ihr Warenkorb ist leer')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = authProvider.userId;
      print('Checkout - userId: $userId');
      print('Checkout - cart total: ${cartProvider.totalPrice}');
      print('Checkout - payment method: $_selectedPaymentMethod');
      
      if (userId == null || userId.isEmpty) {
        throw Exception('Benutzer nicht angemeldet. Bitte melden Sie sich erneut an.');
      }

      final totalAmount = cartProvider.totalPrice;
      if (totalAmount <= 0) {
        throw Exception('Ungültiger Betrag');
      }

      final paymentMethod = _getPaymentMethodBackendValue(_selectedPaymentMethod);
      print('Checkout - calling createPayment with userId: $userId, amount: $totalAmount, method: $paymentMethod');

      // Create payment record in backend (status: PENDING)
      final payment = await paymentService.createPayment(
        userId: userId,
        amount: totalAmount,
        currency: 'EUR',
        paymentMethod: paymentMethod,
        items: cartProvider.items,
      );
      
      print('Checkout - payment created successfully: ${payment['id']}');

      if (mounted) {
        print('Navigating to payment processing screen - method: $_selectedPaymentMethod, paymentId: ${payment['id']}');
        // Navigate to payment processing screen based on selected method
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              paymentMethod: _selectedPaymentMethod,
              amount: totalAmount,
              currency: 'EUR',
              paymentId: payment['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up error message
        errorMessage = errorMessage.replaceAll('Exception: ', '');
        errorMessage = errorMessage.replaceAll('Failed to create payment: ', '');
        
        // Print full error details for debugging
        print('=== PAYMENT ERROR ===');
        print('Error type: ${e.runtimeType}');
        print('Error message: $errorMessage');
        print('Full error: $e');
        print('====================');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zahlung fehlgeschlagen: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentService = Provider.of<PaymentService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasse'),
      ),
      body: cartProvider.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Ihr Warenkorb ist leer'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bestellübersicht',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...cartProvider.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${item.product.name} x${item.quantity}'),
                                    ),
                                    Text(
                                      '${item.totalPrice.toStringAsFixed(2)} €',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Gesamt',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cartProvider.totalPrice.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method Selection
                  const Text(
                    'Zahlungsmethode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...PaymentMethod.values.map((method) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<PaymentMethod>(
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(_getPaymentMethodIcon(method)),
                              const SizedBox(width: 8),
                              Text(_getPaymentMethodName(method)),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Process Payment Button
                  ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _processPayment(cartProvider, authProvider, paymentService),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Jetzt zahlen (${cartProvider.totalPrice.toStringAsFixed(2)} €)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

