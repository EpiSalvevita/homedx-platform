import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/neumorphic.dart';

class OrderSuccessScreen extends StatelessWidget {
  final double amount;
  final String currency;
  final String title;
  final String subtitle;

  const OrderSuccessScreen({
    super.key,
    required this.amount,
    required this.currency,
    this.title = 'Bestellung abgeschlossen',
    this.subtitle = 'Vielen Dank. Ihre Bestellung wurde erfolgreich erfasst.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertig'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, size: 52, color: Colors.green.shade700),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textColorSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                NeumorphicContainer(
                  convex: false,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: AppTheme.textColorSecondary, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gesamt: ${amount.toStringAsFixed(2)} $currency',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                NeumorphicButton(
                  isPrimary: true,
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Zur Startseite'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

