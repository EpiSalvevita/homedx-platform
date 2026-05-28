import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../widgets/figma_ui.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return FigmaScreen(
      header: const FigmaBackHeader(title: 'Warenkorb'),
      bottomBar: cart.isEmpty
          ? null
          : FigmaBottomActionBar(
              buttonLabel: 'Zur Kasse',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            ),
      body: cart.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.textColorSecondary),
                      const SizedBox(height: 16),
                      const Text('Ihr Warenkorb ist leer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                      const SizedBox(height: 8),
                      Text('Stöbern Sie im Shop und fügen Sie Produkte hinzu.', style: TextStyle(color: AppTheme.textColorSecondary), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.neumorphicRaised,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.local_offer, color: AppTheme.primaryBlue, size: 24),
                                  ),
                                  const Spacer(),
                                  _QuantityControls(
                                    quantity: item.quantity,
                                    onDecrement: () {
                                      if (item.quantity <= 1) {
                                        cart.removeItem(item.product.id);
                                      } else {
                                        cart.updateQuantity(item.product.id, item.quantity - 1);
                                      }
                                    },
                                    onIncrement: () => cart.updateQuantity(item.product.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(item.product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                              const SizedBox(height: 4),
                              Text(item.product.description, style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('${item.totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => cart.removeItem(item.product.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text('Entfernen', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.neumorphicRaised,
                    ),
                    child: Column(
                      children: [
                        Text('Gesamt', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                        const SizedBox(height: 6),
                        Text(
                          '${cart.totalPrice.toStringAsFixed(2)} €',
                          style: FigmaUi.rubik(fontSize: 28, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QuantityControls({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyBtn(icon: Icons.remove, onTap: onDecrement),
        SizedBox(width: 36, child: Center(child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)))),
        _QtyBtn(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
