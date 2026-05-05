import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/product.dart';

void main() {
  group('ProductType wire format', () {
    test('every enum member has a stable wire value', () {
      expect(ProductType.physical.wireValue, 'PHYSICAL');
      expect(ProductType.digital.wireValue, 'DIGITAL');
      expect(ProductType.service.wireValue, 'SERVICE');
    });

    test('fromWireValue resolves valid backend strings', () {
      expect(ProductType.fromWireValue('PHYSICAL'), ProductType.physical);
      expect(ProductType.fromWireValue('DIGITAL'), ProductType.digital);
      expect(ProductType.fromWireValue('SERVICE'), ProductType.service);
    });

    test('fromWireValue falls back on null/unknown', () {
      expect(ProductType.fromWireValue(null), ProductType.physical);
      expect(ProductType.fromWireValue(''), ProductType.physical);
      expect(ProductType.fromWireValue('FUTURE_TYPE'), ProductType.physical);
    });
  });

  group('ProductCategory wire format', () {
    test('every enum member has a stable wire value', () {
      expect(ProductCategory.testStrip.wireValue, 'TEST_STRIP');
      expect(ProductCategory.testDevice.wireValue, 'TEST_DEVICE');
      expect(ProductCategory.accessory.wireValue, 'ACCESSORY');
      expect(ProductCategory.other.wireValue, 'OTHER');
    });

    test('fromWireValue resolves valid backend strings', () {
      expect(
        ProductCategory.fromWireValue('TEST_STRIP'),
        ProductCategory.testStrip,
      );
      expect(
        ProductCategory.fromWireValue('TEST_DEVICE'),
        ProductCategory.testDevice,
      );
      expect(
        ProductCategory.fromWireValue('ACCESSORY'),
        ProductCategory.accessory,
      );
      expect(ProductCategory.fromWireValue('OTHER'), ProductCategory.other);
    });

    test('fromWireValue falls back on null/unknown', () {
      expect(ProductCategory.fromWireValue(null), ProductCategory.testStrip);
      expect(
        ProductCategory.fromWireValue('NEW_CATEGORY'),
        ProductCategory.testStrip,
      );
    });
  });

  group('Product.fromJson / toJson', () {
    test('parses a full backend payload', () {
      final json = <String, dynamic>{
        'id': 'p1',
        'name': 'COVID-19 Schnelltest',
        'description': 'Antigen rapid test',
        'price': 24.99,
        'currency': 'EUR',
        'imageUrl': 'https://cdn.example.com/p1.png',
        'type': 'PHYSICAL',
        'category': 'TEST_STRIP',
        'stock': 100,
        'metadata': {'packSize': 5},
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p1');
      expect(product.name, 'COVID-19 Schnelltest');
      expect(product.price, 24.99);
      expect(product.currency, 'EUR');
      expect(product.type, ProductType.physical);
      expect(product.category, ProductCategory.testStrip);
      expect(product.stock, 100);
      expect(product.metadata, {'packSize': 5});
    });

    test('applies defaults for missing optional fields', () {
      final product = Product.fromJson({
        'id': 'p2',
        'name': 'Minimal',
        'description': '',
        'price': 0,
        'type': 'DIGITAL',
        'category': 'OTHER',
      });

      expect(product.currency, 'EUR');
      expect(product.imageUrl, '');
      expect(product.type, ProductType.digital);
      expect(product.category, ProductCategory.other);
      expect(product.stock, isNull);
      expect(product.metadata, isNull);
    });

    test('falls back gracefully on unknown enum strings', () {
      final product = Product.fromJson({
        'id': 'p3',
        'name': 'Future Product',
        'description': '',
        'price': 1,
        'type': 'BUNDLE',
        'category': 'SUBSCRIPTION',
      });

      expect(product.type, ProductType.physical);
      expect(product.category, ProductCategory.testStrip);
    });

    test('toJson emits backend wire values, not Dart names', () {
      final product = Product(
        id: 'p4',
        name: 'Pro Device',
        description: '',
        price: 199.99,
        type: ProductType.physical,
        category: ProductCategory.testDevice,
      );

      final json = product.toJson();

      expect(json['type'], 'PHYSICAL');
      expect(json['category'], 'TEST_DEVICE');
    });

    test('round-trips fromJson -> toJson without losing data', () {
      const original = <String, dynamic>{
        'id': 'p5',
        'name': 'Round Trip',
        'description': 'desc',
        'price': 9.5,
        'currency': 'USD',
        'imageUrl': 'x.png',
        'type': 'SERVICE',
        'category': 'ACCESSORY',
        'stock': 7,
        'metadata': {'k': 'v'},
      };

      final out = Product.fromJson(original).toJson();

      expect(out['type'], 'SERVICE');
      expect(out['category'], 'ACCESSORY');
      expect(out['id'], 'p5');
      expect(out['price'], 9.5);
      expect(out['currency'], 'USD');
      expect(out['stock'], 7);
      expect(out['metadata'], {'k': 'v'});
    });
  });
}
