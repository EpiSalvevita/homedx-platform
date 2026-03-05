import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SEPAPaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String paymentId;
  final Function() onPaymentComplete;
  final Function() onPaymentCancelled;

  const SEPAPaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.paymentId,
    required this.onPaymentComplete,
    required this.onPaymentCancelled,
  });

  @override
  State<SEPAPaymentScreen> createState() => _SEPAPaymentScreenState();
}

class _SEPAPaymentScreenState extends State<SEPAPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _accountHolderController = TextEditingController();

  @override
  void dispose() {
    _ibanController.dispose();
    _bicController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  String _formatIBAN(String value) {
    // Remove all non-alphanumeric characters
    value = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    // Add spaces every 4 characters
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  bool _validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    // Remove spaces
    final iban = value.replaceAll(' ', '').toUpperCase();
    // IBAN should be 15-34 characters
    if (iban.length < 15 || iban.length > 34) {
      return false;
    }
    // Basic format check: starts with 2 letters, then 2 digits, then alphanumeric
    if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$').hasMatch(iban)) {
      return false;
    }
    return true;
  }

  bool _validateBIC(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    // BIC should be 8 or 11 characters
    final bic = value.replaceAll(' ', '').toUpperCase();
    if (bic.length != 8 && bic.length != 11) {
      return false;
    }
    // Format: 4 letters, 2 letters, 2 alphanumeric, optional 3 alphanumeric
    if (!RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(bic)) {
      return false;
    }
    return true;
  }

  void _copyBankDetails() {
    final bankDetails = '''
IBAN: DE89 3704 0044 0532 0130 00
BIC: COBADEFFXXX
Kontoinhaber: HomeDX GmbH
Verwendungszweck: ${widget.paymentId}
Betrag: ${widget.amount.toStringAsFixed(2)} ${widget.currency}
''';
    Clipboard.setData(ClipboardData(text: bankDetails));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bankverbindung in Zwischenablage kopiert')),
    );
  }

  Future<void> _confirmPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SEPA-Überweisung bestätigen'),
        content: const Text(
          'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen auf das angegebene Konto. '
          'Verwenden Sie die Zahlungs-ID als Verwendungszweck.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onPaymentComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEPA-Überweisung'),
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

              // Bank Details Section
              const Text(
                'Bankverbindung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'IBAN:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Kopieren'),
                            onPressed: _copyBankDetails,
                          ),
                        ],
                      ),
                      const Text(
                        'DE89 3704 0044 0532 0130 00',
                        style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BIC:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'COBADEFFXXX',
                        style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kontoinhaber:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'HomeDX GmbH',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Verwendungszweck:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.paymentId,
                        style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Your Bank Details (Optional)
              const Text(
                'Ihre Bankverbindung (optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diese Angaben sind optional und werden nur für Ihre Referenz gespeichert.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // IBAN
              TextFormField(
                controller: _ibanController,
                decoration: const InputDecoration(
                  labelText: 'IBAN (optional)',
                  hintText: 'DE89 3704 0044 0532 0130 00',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatIBAN(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty && !_validateIBAN(value)) {
                    return 'Ungültige IBAN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // BIC
              TextFormField(
                controller: _bicController,
                decoration: const InputDecoration(
                  labelText: 'BIC (optional)',
                  hintText: 'COBADEFFXXX',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty && !_validateBIC(value)) {
                    return 'Ungültiger BIC';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Holder
              TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Kontoinhaber (optional)',
                  hintText: 'Max Mustermann',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen. '
                        'Verwenden Sie die Zahlungs-ID als Verwendungszweck, damit wir Ihre Zahlung zuordnen können.',
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

              // Confirm Button
              ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Überweisung bestätigen',
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




