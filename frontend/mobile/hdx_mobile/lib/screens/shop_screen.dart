import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/shop_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';
import '../widgets/web/web_action_chip.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final products = await _shopService.getProducts();
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return AdaptiveScreen(
      title: 'Shop',
      showWebHeader: false,
      onBack: () => context.go('/home'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              8,
              kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
              16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FigmaSegmentedTabs(
                    labels: const ['Alle', 'Teststreifen', 'Testgeräte'],
                    selectedIndex: _selectedCategory == null
                        ? 0
                        : _selectedCategory == ProductCategory.testStrip
                            ? 1
                            : 2,
                    onSelected: (i) => setState(() {
                      _selectedCategory = i == 0 ? null : i == 1 ? ProductCategory.testStrip : ProductCategory.testDevice;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                _CartIconButton(cartProvider: cartProvider),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? FigmaEmptyState(
                        icon: Icons.error_outline,
                        title: 'Shop konnte nicht geladen werden',
                        message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                        actionLabel: 'Erneut versuchen',
                        onAction: _loadProducts,
                      )
                    : _filteredProducts.isEmpty
                        ? const FigmaEmptyState(
                            icon: Icons.storefront_outlined,
                            title: 'Keine Produkte gefunden',
                            message: 'In dieser Kategorie sind derzeit keine Artikel verfügbar.',
                          )
                        : kIsWeb
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              final cols = webGridColumnCount(constraints.maxWidth);
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.82,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) => _ProductCard(
                                  product: _filteredProducts[index],
                                  cartProvider: cartProvider,
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                            itemCount: _filteredProducts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _ProductCard(product: _filteredProducts[index], cartProvider: cartProvider),
                          ),
          ),
        ],
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  final CartProvider cartProvider;
  const _CartIconButton({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppTheme.largeTouchTarget,
      height: AppTheme.largeTouchTarget,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: AppTheme.largeTouchTarget,
              minHeight: AppTheme.largeTouchTarget,
            ),
            icon: const Icon(Icons.shopping_cart_outlined, size: 26),
            tooltip: 'Warenkorb',
            onPressed: () => context.push('/shop/cart'),
          ),
          if (cartProvider.itemCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${cartProvider.itemCount}',
                    style: FigmaUi.rubik(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final CartProvider cartProvider;
  const _ProductCard({required this.product, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    final cartItem = cartProvider.getItem(product.id);
    final isInCart = cartItem != null;

    return GestureDetector(
      onTap: () => context.push('/shop/product', extra: product),
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
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sell_outlined, color: AppTheme.primaryBlue, size: 26),
                ),
                const Spacer(),
                if (isInCart)
                  _QuantityControls(
                    quantity: cartItem.quantity,
                    onDecrement: () {
                      if (cartItem.quantity > 1) {
                        cartProvider.updateQuantity(product.id, cartItem.quantity - 1);
                      } else {
                        cartProvider.removeItem(product.id);
                      }
                    },
                    onIncrement: () => cartProvider.updateQuantity(product.id, cartItem.quantity + 1),
                  )
                else
                  GestureDetector(
                    onTap: product.stock != null && product.stock! <= 0
                        ? null
                        : () {
                            cartProvider.addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} hinzugefügt'), duration: const Duration(seconds: 1)),
                            );
                          },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryBlue, size: 24),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(product.name, style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
            const SizedBox(height: 6),
            Text(product.description, style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0x1A142543)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${product.price.toStringAsFixed(2)} €', style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                if (product.stock != null) ...[
                  const SizedBox(width: 14),
                  Text(
                    '${product.stock} verfügbar',
                    style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
                  ),
                ],
              ],
            ),
          ],
        ),
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
        _QtyBtn(icon: Icons.remove, onTap: onDecrement, neumorphic: true),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$quantity',
              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textColor),
            ),
          ),
        ),
        _QtyBtn(icon: Icons.add, onTap: onIncrement, neumorphic: true),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool neumorphic;
  const _QtyBtn({required this.icon, required this.onTap, this.neumorphic = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: neumorphic ? AppTheme.neumorphicRaised : null,
        ),
        child: Icon(icon, color: AppTheme.textColor, size: 22),
      ),
    );
  }
}
