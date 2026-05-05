import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/shop_service.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          _CartIconButton(cartProvider: cartProvider),
        ],
      ),
      body: Column(
        children: [
          // Category filter tabs
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(label: 'Alle', isSelected: _selectedCategory == null, onTap: () => setState(() => _selectedCategory = null)),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Teststreifen', isSelected: _selectedCategory == ProductCategory.testStrip, onTap: () => setState(() => _selectedCategory = ProductCategory.testStrip)),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Testgeräte', isSelected: _selectedCategory == ProductCategory.testDevice, onTap: () => setState(() => _selectedCategory = ProductCategory.testDevice)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Fehler: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadProducts, child: const Text('Erneut versuchen')),
                      ]))
                    : _filteredProducts.isEmpty
                        ? const Center(child: Text('Keine Produkte gefunden'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.primaryBlue,
            ),
          ),
        ),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
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
            Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 4),
            Text(product.description, style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${product.price.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
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
        _QtyBtn(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 36,
          child: Center(child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor))),
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
