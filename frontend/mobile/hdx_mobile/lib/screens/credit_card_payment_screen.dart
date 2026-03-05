import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:provider/provider.dart';
import '../services/payment_service.dart';

class CreditCardPaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String paymentId;
  final Function(String transactionId) onPaymentComplete;
  final Function(String error) onPaymentFailed;

  const CreditCardPaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.paymentId,
    required this.onPaymentComplete,
    required this.onPaymentFailed,
  });

  @override
  State<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends State<CreditCardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    // Add spaces every 4 digits
    if (value.length > 4) {
      value = value.substring(0, 4) + ' ' + value.substring(4);
    }
    if (value.length > 9) {
      value = value.substring(0, 9) + ' ' + value.substring(9);
    }
    if (value.length > 14) {
      value = value.substring(0, 14) + ' ' + value.substring(14);
    }
    return value;
  }

  String _formatExpiry(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    // Add slash after 2 digits
    if (value.length >= 2) {
      value = value.substring(0, 2) + '/' + value.substring(2);
    }
    return value;
  }

  bool _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    // Remove spaces and check if it's 13-19 digits
    final digits = value.replaceAll(' ', '');
    if (digits.length < 13 || digits.length > 19) {
      return false;
    }
    // Luhn algorithm check
    return _luhnCheck(digits);
  }

  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10) == 0;
  }

  bool _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return false;
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) {
      return false;
    }
    if (month < 1 || month > 12) {
      return false;
    }
    // Check if expiry is in the future
    final now = DateTime.now();
    final expiryYear = 2000 + year;
    if (expiryYear < now.year || (expiryYear == now.year && month < now.month)) {
      return false;
    }
    return true;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('Credit card payment - Starting payment process for paymentId: ${widget.paymentId}');
      final paymentService = Provider.of<PaymentService>(context, listen: false);

      // Step 1: Create payment intent via backend
      print('Credit card payment - Creating Stripe payment intent...');
      final clientSecret = await paymentService.createStripePaymentIntent(
        paymentId: widget.paymentId,
        amount: widget.amount,
        currency: widget.currency,
      );
      print('Credit card payment - Payment intent created, clientSecret received');

      // Step 2: Create payment method with Stripe using card details
      final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: stripe.BillingDetails(
              name: _cardholderNameController.text,
            ),
          ),
        ),
      );

      // Step 3: Confirm payment with Stripe using the payment method ID
      await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: stripe.BillingDetails(
              name: _cardholderNameController.text,
            ),
          ),
        ),
      );

      // Step 4: Get transaction ID from payment method
      // Use the payment method ID as the transaction identifier
      final transactionId = paymentMethod.id;

      widget.onPaymentComplete(transactionId);
    } on stripe.StripeException catch (e) {
      // Handle Stripe-specific errors
      String errorMessage = 'Zahlung fehlgeschlagen';
      if (e.error.code == stripe.FailureCode.Canceled) {
        errorMessage = 'Zahlung wurde abgebrochen';
      } else if (e.error.message != null) {
        errorMessage = e.error.message!;
      }
      widget.onPaymentFailed(errorMessage);
    } catch (e) {
      widget.onPaymentFailed(e.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreditkartenzahlung'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Display
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Zu zahlender Betrag:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Kartennummer',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatCardNumber(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihre Kartennummer ein';
                  }
                  if (!_validateCardNumber(value)) {
                    return 'Ungültige Kartennummer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _cardholderNameController,
                decoration: const InputDecoration(
                  labelText: 'Karteninhaber',
                  hintText: 'Max Mustermann',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Namen des Karteninhabers ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Ablaufdatum',
                        hintText: 'MM/JJ',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final formatted = _formatExpiry(newValue.text);
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'MM/JJ';
                        }
                        if (!_validateExpiry(value)) {
                          return 'Ungültiges Ablaufdatum';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVV';
                        }
                        if (value.length < 3) {
                          return 'Ungültiger CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ihre Zahlungsdaten werden sicher verschlüsselt übertragen.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pay Button
              ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
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
                    : const Text(
                        'Jetzt zahlen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

