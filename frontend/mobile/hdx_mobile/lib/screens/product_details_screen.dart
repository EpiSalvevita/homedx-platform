import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/neumorphic.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context);
    final inStock = widget.product.stock == null || widget.product.stock! > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produkt'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            NeumorphicContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} €',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (widget.product.stock != null)
                        Text(
                          inStock ? '${widget.product.stock} verfügbar' : 'Ausverkauft',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: inStock ? Colors.green.shade700 : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textColorSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            NeumorphicContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Menge',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      NeumorphicButton(
                        onPressed: _quantity <= 1 ? null : () => setState(() => _quantity -= 1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: const Icon(Icons.remove, size: 22),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ),
                      NeumorphicButton(
                        onPressed: () => setState(() => _quantity += 1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: const Icon(Icons.add, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    isPrimary: true,
                    onPressed: !inStock
                        ? null
                        : () {
                            cart.addItem(widget.product, quantity: _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.name} zum Warenkorb hinzugefügt'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: const Text('In den Warenkorb'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

