import 'package:cometake/features/cart/domain/entities/cart.dart';
import 'package:cometake/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

CartItem item({
  String id = 'item-1',
  String productId = 'prod-1',
  String productName = 'Test Product',
  double price = 1000,
  double? comparePrice,
  int quantity = 1,
}) =>
    CartItem(
      id: id,
      productId: productId,
      productName: productName,
      price: price,
      comparePrice: comparePrice,
      quantity: quantity,
    );

Product product({
  String id = 'prod-1',
  String name = 'Test',
  double price = 1000,
  double? comparePrice,
  List<String> images = const [],
}) =>
    Product(
      id: id,
      name: name,
      description: '',
      price: price,
      comparePrice: comparePrice,
      sku: 'SKU-1',
      images: images,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  // ── CartItem ───────────────────────────────────────────────────────────────

  group('CartItem.subtotal', () {
    test('single quantity: subtotal equals price', () {
      expect(item(price: 500).subtotal, 500.0);
    });

    test('multiple quantity: subtotal is price × quantity', () {
      expect(item(price: 500, quantity: 3).subtotal, 1500.0);
    });

    test('fractional price: subtotal is precise', () {
      expect(item(price: 99.99, quantity: 2).subtotal, closeTo(199.98, 0.01));
    });
  });

  group('CartItem.hasDiscount', () {
    test('no comparePrice → hasDiscount is false', () {
      expect(item(price: 1000).hasDiscount, isFalse);
    });

    test('comparePrice == price → hasDiscount is false', () {
      expect(item(price: 1000, comparePrice: 1000).hasDiscount, isFalse);
    });

    test('comparePrice < price → hasDiscount is false (inverted price)', () {
      expect(item(price: 1000, comparePrice: 800).hasDiscount, isFalse);
    });

    test('comparePrice > price → hasDiscount is true', () {
      expect(item(price: 800, comparePrice: 1000).hasDiscount, isTrue);
    });

    test('comparePrice of 0 → hasDiscount is false', () {
      expect(item(price: 1000, comparePrice: 0).hasDiscount, isFalse);
    });
  });

  // ── Cart ──────────────────────────────────────────────────────────────────

  group('Cart.isEmpty', () {
    test('empty cart is empty', () {
      expect(const Cart().isEmpty, isTrue);
    });

    test('cart with one item is not empty', () {
      expect(Cart(items: [item()]).isEmpty, isFalse);
    });
  });

  group('Cart.totalItems', () {
    test('empty cart has 0 total items', () {
      expect(const Cart().totalItems, 0);
    });

    test('single item with quantity 1', () {
      expect(Cart(items: [item()]).totalItems, 1);
    });

    test('single item with quantity 3', () {
      expect(Cart(items: [item(quantity: 3)]).totalItems, 3);
    });

    test('multiple items: quantities are summed', () {
      final cart = Cart(items: [
        item(id: 'a', quantity: 2),
        item(id: 'b', quantity: 3),
      ],);
      expect(cart.totalItems, 5);
    });
  });

  group('Cart.subtotal', () {
    test('empty cart subtotal is 0', () {
      expect(const Cart().subtotal, 0.0);
    });

    test('single item subtotal', () {
      expect(Cart(items: [item(price: 500, quantity: 2)]).subtotal, 1000.0);
    });

    test('multiple items: subtotals are summed', () {
      final cart = Cart(items: [
        item(id: 'a', price: 1000),
        item(id: 'b', price: 500, quantity: 2),
      ],);
      expect(cart.subtotal, 2000.0);
    });

    test('subtotal accounts for quantity of each item', () {
      final cart = Cart(items: [
        item(id: 'x', price: 100, quantity: 3), // 300
        item(id: 'y', price: 200, quantity: 2), // 400
      ],);
      expect(cart.subtotal, 700.0);
    });
  });

  // ── Product ───────────────────────────────────────────────────────────────

  group('Product.hasDiscount', () {
    test('no comparePrice → no discount', () {
      expect(product(price: 1000).hasDiscount, isFalse);
    });

    test('comparePrice == price → no discount', () {
      expect(product(price: 1000, comparePrice: 1000).hasDiscount, isFalse);
    });

    test('comparePrice less than price → no discount (bad data)', () {
      expect(product(price: 1000, comparePrice: 800).hasDiscount, isFalse);
    });

    test('comparePrice greater than price → has discount', () {
      expect(product(price: 800, comparePrice: 1000).hasDiscount, isTrue);
    });
  });

  group('Product.discountPercent', () {
    test('no discount → 0%', () {
      expect(product(price: 1000).discountPercent, 0);
    });

    test('20% off: (1000 - 800) / 1000 * 100 = 20', () {
      expect(product(price: 800, comparePrice: 1000).discountPercent, 20);
    });

    test('50% off', () {
      expect(product(price: 500, comparePrice: 1000).discountPercent, 50);
    });

    test('rounds to nearest integer', () {
      // (1000 - 666) / 1000 * 100 = 33.4 → rounds to 33
      expect(product(price: 666, comparePrice: 1000).discountPercent, 33);
    });
  });

  group('Product.thumbnailUrl', () {
    test('no images → null', () {
      expect(product().thumbnailUrl, isNull);
    });

    test('first image is thumbnail', () {
      final p = product(images: const ['img1.jpg', 'img2.jpg']);
      expect(p.thumbnailUrl, 'img1.jpg');
    });

    test('single image is thumbnail', () {
      final p = product(images: const ['cover.jpg']);
      expect(p.thumbnailUrl, 'cover.jpg');
    });
  });

  // ── ProductVendor ─────────────────────────────────────────────────────────

  group('ProductVendor.fullName', () {
    test('concatenates first and last name', () {
      const v = ProductVendor(id: 'v1', firstName: 'John', lastName: 'Doe');
      expect(v.fullName, 'John Doe');
    });

    test('trims when last name is empty', () {
      const v = ProductVendor(id: 'v2', firstName: 'John', lastName: '');
      expect(v.fullName, 'John');
    });

    test('trims when first name is empty', () {
      const v = ProductVendor(id: 'v3', firstName: '', lastName: 'Doe');
      expect(v.fullName, 'Doe');
    });
  });
}
