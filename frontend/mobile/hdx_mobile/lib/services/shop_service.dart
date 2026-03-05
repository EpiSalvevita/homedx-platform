import '../models/product.dart';

class ShopService {
  ShopService();

  // Mock products for now - in production, fetch from backend
  Future<List<Product>> getProducts() async {
    // TODO: Replace with actual API call when backend endpoint is ready
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    return [
      // Test Strips
      Product(
        id: 'test-strip-1',
        name: 'COVID-19 Schnelltest (5er Pack)',
        description: 'Schnelltest für COVID-19 Antigen. Enthält 5 Teststreifen.',
        price: 24.99,
        currency: 'EUR',
        type: ProductType.PHYSICAL,
        category: ProductCategory.TEST_STRIP,
        stock: 100,
        metadata: {'packSize': 5, 'testType': 'COVID-19'},
      ),
      Product(
        id: 'test-strip-2',
        name: 'RheumaCheck Teststreifen (10er Pack)',
        description: 'Teststreifen für RheumaCheck. Enthält 10 Teststreifen.',
        price: 49.99,
        currency: 'EUR',
        type: ProductType.PHYSICAL,
        category: ProductCategory.TEST_STRIP,
        stock: 50,
        metadata: {'packSize': 10, 'testType': 'RheumaCheck'},
      ),
      Product(
        id: 'test-strip-3',
        name: 'Vitamin D Teststreifen (3er Pack)',
        description: 'Teststreifen für Vitamin D Test. Enthält 3 Teststreifen.',
        price: 19.99,
        currency: 'EUR',
        type: ProductType.PHYSICAL,
        category: ProductCategory.TEST_STRIP,
        stock: 75,
        metadata: {'packSize': 3, 'testType': 'Vitamin D'},
      ),
      // Test Devices
      Product(
        id: 'test-device-1',
        name: 'HomeDX Testgerät Pro',
        description: 'Professionelles Testgerät für zu Hause. Bluetooth-fähig, kompatibel mit allen HomeDX Teststreifen.',
        price: 199.99,
        currency: 'EUR',
        type: ProductType.PHYSICAL,
        category: ProductCategory.TEST_DEVICE,
        stock: 25,
        metadata: {'bluetooth': true, 'battery': 'rechargeable'},
      ),
      Product(
        id: 'test-device-2',
        name: 'HomeDX Testgerät Basic',
        description: 'Einfaches Testgerät für den Einstieg. Kompatibel mit allen HomeDX Teststreifen.',
        price: 99.99,
        currency: 'EUR',
        type: ProductType.PHYSICAL,
        category: ProductCategory.TEST_DEVICE,
        stock: 40,
        metadata: {'bluetooth': false, 'battery': 'AA'},
      ),
    ];
  }

  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    final products = await getProducts();
    return products.where((product) => product.category == category).toList();
  }
}




