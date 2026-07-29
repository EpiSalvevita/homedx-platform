import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  String get _categoryLabel {
    switch (widget.product.category) {
      case ProductCategory.testStrip:
        return 'Teststreifen';
      case ProductCategory.testDevice:
        return 'Testgerät';
      case ProductCategory.accessory:
        return 'Zubehör';
      case ProductCategory.other:
        return 'Sonstiges';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inStock = widget.product.stock == null || widget.product.stock! > 0;

    return AdaptiveScreen(
      title: widget.product.name,
      showWebHeader: false,
      onBack: () => context.canPop() ? context.pop() : context.go('/shop'),
      body: SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.sell_outlined,
                              color: AppTheme.primaryBlue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: FigmaUi.rubik(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _categoryLabel,
                                  style: FigmaUi.bodyLight(fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1, color: Color(0x1A142543)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${widget.product.price.toStringAsFixed(2)} €',
                            style: FigmaUi.rubik(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const Spacer(),
                          if (widget.product.stock != null && !inStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCoral.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
                              ),
                              child: Text(
                                'Ausverkauft',
                                style: FigmaUi.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.product.description,
                        style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                NeumorphicRaisedCard(
                  height: null,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Menge',
                        style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _QtyBtn(
                            icon: Icons.remove,
                            onTap: _quantity <= 1 ? null : () => setState(() => _quantity -= 1),
                          ),
                          SizedBox(
                            width: 72,
                            child: Center(
                              child: Text(
                                '$_quantity',
                                style: FigmaUi.rubik(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add,
                            onTap: () => setState(() => _quantity += 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Gesamt: ${(widget.product.price * _quantity).toStringAsFixed(2)} €',
                        textAlign: TextAlign.center,
                        style: FigmaUi.rubik(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: inStock ? 'In den Warenkorb' : 'Derzeit nicht verfügbar',
                  leadingIcon: Icons.shopping_cart_outlined,
                  height: AppTheme.buttonHeightLarge,
                  backgroundColor: inStock ? AppTheme.accentBlue : AppTheme.surface,
                  foregroundColor: inStock ? Colors.white : AppTheme.textColorSecondary,
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
                ),
                const SizedBox(height: 16),
                NeumorphicPillButton(
                  label: 'Warenkorb anzeigen',
                  leadingIcon: Icons.shopping_bag_outlined,
                  height: AppTheme.buttonHeightLarge,
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  onPressed: () => context.push('/shop/cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.neumorphicRaised,
          ),
          child: Icon(icon, color: AppTheme.textColor, size: 22),
        ),
      ),
    );
  }
}
