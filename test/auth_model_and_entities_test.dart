import 'package:cometake/features/auth/data/models/auth_user_model.dart';
import 'package:cometake/features/orders/domain/entities/order.dart';
import 'package:cometake/features/wallet/domain/entities/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── authUserModelFromRow ───────────────────────────────────────────────────

  group('authUserModelFromRow: name assembly', () {
    test('joins first_name and last_name with a space', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'a@b.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'is_superuser': false,
        'is_staff': false,
        'is_seller': false,
        'verified_email': false,
      });
      expect(m.fullName, 'John Doe');
    });

    test('omits empty last_name (no trailing space)', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'a@b.com',
        'first_name': 'John',
        'last_name': '',
        'is_superuser': false,
        'is_staff': false,
        'is_seller': false,
        'verified_email': false,
      });
      expect(m.fullName, 'John');
    });

    test('omits empty first_name (no leading space)', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'a@b.com',
        'first_name': '',
        'last_name': 'Doe',
        'is_superuser': false,
        'is_staff': false,
        'is_seller': false,
        'verified_email': false,
      });
      expect(m.fullName, 'Doe');
    });

    test('handles both names empty → empty fullName', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'a@b.com',
        'first_name': '',
        'last_name': '',
        'is_superuser': false,
        'is_staff': false,
        'is_seller': false,
        'verified_email': false,
      });
      expect(m.fullName, '');
    });

    test('handles null names by treating them as empty', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'a@b.com',
        'first_name': null,
        'last_name': null,
        'verified_email': false,
      });
      expect(m.fullName, '');
    });
  });

  group('authUserModelFromRow: role resolution', () {
    Map<String, dynamic> row({
      bool superuser = false,
      bool staff = false,
      bool seller = false,
    }) =>
        {
          'id': 'u1',
          'email': 'a@b.com',
          'first_name': 'A',
          'last_name': 'B',
          'is_superuser': superuser,
          'is_staff': staff,
          'is_seller': seller,
          'verified_email': false,
        };

    test('is_superuser=true → role is "admin"', () {
      expect(authUserModelFromRow(row(superuser: true)).role, 'admin');
    });

    test('is_staff=true → role is "admin"', () {
      expect(authUserModelFromRow(row(staff: true)).role, 'admin');
    });

    test('is_seller=true (not admin) → role is "seller"', () {
      expect(authUserModelFromRow(row(seller: true)).role, 'seller');
    });

    test('none set → role is "customer"', () {
      expect(authUserModelFromRow(row()).role, 'customer');
    });

    test('is_superuser trumps is_seller when both true', () {
      expect(authUserModelFromRow(row(superuser: true, seller: true)).role, 'admin');
    });
  });

  group('authUserModelFromRow: other fields', () {
    test('verified_email maps to isVerified', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'x@y.com',
        'first_name': 'A',
        'last_name': 'B',
        'is_superuser': false,
        'is_staff': false,
        'is_seller': false,
        'verified_email': true,
      });
      expect(m.isVerified, isTrue);
    });

    test('photo maps to avatarUrl', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'x@y.com',
        'first_name': 'A',
        'last_name': 'B',
        'photo': 'https://example.com/photo.jpg',
        'verified_email': false,
      });
      expect(m.avatarUrl, 'https://example.com/photo.jpg');
    });

    test('null photo → null avatarUrl', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'x@y.com',
        'first_name': 'A',
        'last_name': 'B',
        'photo': null,
        'verified_email': false,
      });
      expect(m.avatarUrl, isNull);
    });

    test('created_at ISO string is parsed to DateTime', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'x@y.com',
        'first_name': 'A',
        'last_name': 'B',
        'verified_email': false,
        'created_at': '2024-01-15T12:00:00.000Z',
      });
      expect(m.createdAt, isA<DateTime>());
      expect(m.createdAt!.year, 2024);
    });

    test('null created_at → null createdAt', () {
      final m = authUserModelFromRow({
        'id': 'u1',
        'email': 'x@y.com',
        'first_name': 'A',
        'last_name': 'B',
        'verified_email': false,
        'created_at': null,
      });
      expect(m.createdAt, isNull);
    });
  });

  // ── AuthUserModel.fromJson ─────────────────────────────────────────────────

  group('AuthUserModel.fromJson', () {
    test('maps id, email, full_name (JsonKey)', () {
      final m = AuthUserModel.fromJson({
        'id': 'user-42',
        'email': 'jane@example.com',
        'full_name': 'Jane Smith',
      });
      expect(m.id, 'user-42');
      expect(m.email, 'jane@example.com');
      expect(m.fullName, 'Jane Smith');
    });

    test('defaults role to "customer" when absent', () {
      final m = AuthUserModel.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'full_name': 'A B',
      });
      expect(m.role, 'customer');
    });

    test('defaults isVerified to false when absent', () {
      final m = AuthUserModel.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'full_name': 'A B',
      });
      expect(m.isVerified, isFalse);
    });

    test('reads avatar_url via JsonKey', () {
      final m = AuthUserModel.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'full_name': 'A B',
        'avatar_url': 'https://cdn.example.com/avatar.png',
      });
      expect(m.avatarUrl, 'https://cdn.example.com/avatar.png');
    });
  });

  // ── Order entity ───────────────────────────────────────────────────────────

  group('Order.itemCount', () {
    test('empty items list → 0', () {
      final o = Order(
        id: 'ord-1',
        orderNumber: 'ORD-001',
        total: 0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(o.itemCount, 0);
    });

    test('single item with quantity 1', () {
      final o = Order(
        id: 'ord-1',
        orderNumber: 'ORD-001',
        total: 1000,
        createdAt: DateTime(2024, 1, 1),
        items: const [
          OrderItem(id: 'i1', quantity: 1, price: 1000, total: 1000),
        ],
      );
      expect(o.itemCount, 1);
    });

    test('multiple items: quantities are summed', () {
      final o = Order(
        id: 'ord-1',
        orderNumber: 'ORD-001',
        total: 5000,
        createdAt: DateTime(2024, 1, 1),
        items: const [
          OrderItem(id: 'i1', quantity: 2, price: 1000, total: 2000),
          OrderItem(id: 'i2', quantity: 3, price: 1000, total: 3000),
        ],
      );
      expect(o.itemCount, 5);
    });
  });

  // ── Address entity ─────────────────────────────────────────────────────────

  group('Address.summary', () {
    test('concatenates street, city, state with commas', () {
      const a = Address(
        id: 'addr-1',
        fullName: 'John',
        phone: '080',
        street: '10 Victoria Island',
        city: 'Lagos',
        state: 'Lagos',
      );
      expect(a.summary, '10 Victoria Island, Lagos, Lagos');
    });

    test('uses default country Nigeria when omitted', () {
      const a = Address(
        id: 'addr-2',
        fullName: 'Jane',
        phone: '080',
        street: 'Main St',
        city: 'Abuja',
        state: 'FCT',
      );
      expect(a.country, 'Nigeria');
    });

    test('isDefault defaults to false', () {
      const a = Address(
        id: 'addr-3',
        fullName: 'A',
        phone: '080',
        street: 'S',
        city: 'C',
        state: 'ST',
      );
      expect(a.isDefault, isFalse);
    });
  });

  // ── WalletTxType ───────────────────────────────────────────────────────────

  group('WalletTxType.fromString', () {
    test('"credit" → WalletTxType.credit', () {
      expect(WalletTxType.fromString('credit'), WalletTxType.credit);
    });

    test('"CREDIT" (uppercase) → WalletTxType.credit', () {
      expect(WalletTxType.fromString('CREDIT'), WalletTxType.credit);
    });

    test('"debit" → WalletTxType.debit', () {
      expect(WalletTxType.fromString('debit'), WalletTxType.debit);
    });

    test('any non-credit string → WalletTxType.debit', () {
      expect(WalletTxType.fromString('DEBIT'), WalletTxType.debit);
      expect(WalletTxType.fromString('unknown'), WalletTxType.debit);
    });
  });

  group('WalletTxType.displayName', () {
    test('credit displayName is "Credit"', () {
      expect(WalletTxType.credit.displayName, 'Credit');
    });

    test('debit displayName is "Debit"', () {
      expect(WalletTxType.debit.displayName, 'Debit');
    });
  });

  // ── WalletTransaction.isCredit ─────────────────────────────────────────────

  group('WalletTransaction.isCredit', () {
    WalletTransaction tx(WalletTxType type) => WalletTransaction(
          id: 'tx-1',
          walletId: 'w-1',
          type: type,
          amount: 1000,
          balanceBefore: 0,
          balanceAfter: 1000,
          description: 'Test',
          reference: 'REF-1',
          createdAt: DateTime(2024, 1, 1),
        );

    test('credit type → isCredit is true', () {
      expect(tx(WalletTxType.credit).isCredit, isTrue);
    });

    test('debit type → isCredit is false', () {
      expect(tx(WalletTxType.debit).isCredit, isFalse);
    });
  });
}
