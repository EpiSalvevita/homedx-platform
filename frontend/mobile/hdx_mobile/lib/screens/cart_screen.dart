import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return AdaptiveScreen(
      title: 'Warenkorb',
      showWebHeader: false,
      onBack: () => context.canPop() ? context.pop() : context.go('/shop'),
      bottomBar: cart.isEmpty
          ? null
          : FigmaBottomActionBar(
              buttonLabel: 'Zur Kasse',
              onPressed: () => context.push('/shop/checkout'),
            ),
      body: cart.isEmpty
          ? FigmaEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Ihr Warenkorb ist leer',
              message: 'Stöbern Sie im Shop und fügen Sie Produkte hinzu.',
              actionLabel: 'Zum Shop',
              onAction: () => context.go('/shop'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                      kIsWeb ? 24 : 16,
                      kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                      16,
                    ),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Container(
                            padding: const EdgeInsets.all(20),
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
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.local_offer, color: AppTheme.primaryBlue, size: 26),
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
                                const SizedBox(height: 14),
                                Text(
                                  item.product.name,
                                  style: FigmaUi.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.product.description,
                                  style: FigmaUi.rubik(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textColorSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1, color: Color(0x1A142543)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text(
                                      '${item.totalPrice.toStringAsFixed(2)} €',
                                      style: FigmaUi.rubik(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => cart.removeItem(item.product.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Entfernen',
                                          style: FigmaUi.rubik(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                        kIsWeb ? 32 : 16,
                        0,
                        kIsWeb ? 32 : 16,
                        8,
                      ),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.neumorphicRaised,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Gesamt',
                            style: FigmaUi.rubik(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${cart.totalPrice.toStringAsFixed(2)} €',
                            style: FigmaUi.rubik(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$quantity',
              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textColor),
            ),
          ),
        ),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
