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
      onBack: () => context.go('/home'),
      actions: [_CartIconButton(cartProvider: cartProvider)],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.screenHorizontalPadding, 8, AppTheme.screenHorizontalPadding, 12),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Fehler: $_error', style: FigmaUi.rubik(color: AppTheme.textColor)),
                        const SizedBox(height: 16),
                        NeumorphicPillButton(label: 'Erneut versuchen', height: 52, onPressed: _loadProducts),
                      ]))
                    : _filteredProducts.isEmpty
                        ? Center(child: Text('Keine Produkte gefunden', style: FigmaUi.rubik(color: AppTheme.textColor)))
                        : kIsWeb
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              final cols = webGridColumnCount(constraints.maxWidth);
                              return GridView.builder(
                                padding: const EdgeInsets.all(24),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
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
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
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
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => context.push('/shop/cart'),
        ),
        if (cartProvider.itemCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle),
              child: Center(
                child: Text('${cartProvider.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
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
                  child: const Icon(Icons.sell_outlined, color: AppTheme.primaryBlue, size: 22),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryBlue, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(product.name, style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
            const SizedBox(height: 4),
            Text(product.description, style: FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0x1A142543)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${product.price.toStringAsFixed(2)} €', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue)),
                if (product.stock != null) ...[
                  const SizedBox(width: 14),
                  Text('${product.stock} verfügbar', style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary)),
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
          width: 36,
          child: Center(child: Text('$quantity', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor))),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: neumorphic ? AppTheme.neumorphicRaised : null,
        ),
        child: Icon(icon, color: AppTheme.textColor, size: 22),
      ),
    );
  }
}
