// LIVE integration test — hits a real Supabase project over the network.
// This is NOT part of the normal `flutter test` suite: every test below is
// skipped unless all three env vars are present, so CI and everyday local
// runs are unaffected. Run it deliberately with:
//
//   flutter test test/integration/delete_account_real_jwt_integration_test.dart \
//     --dart-define=COMETAKE_TEST_SUPABASE_URL=https://xxxx.supabase.co \
//     --dart-define=COMETAKE_TEST_SUPABASE_ANON_KEY=eyJ... \
//     --dart-define=COMETAKE_TEST_SUPABASE_SERVICE_ROLE_KEY=eyJ...
//
// Why a service-role key is required at all: only to seed rows (orders,
// addresses, cart_items, core_saveditems) for the throwaway test users and
// to read back post-deletion DB state directly for assertions — the same
// credential tier the delete-account Edge Function itself holds
// server-side. It is NEVER the credential presented *to* the function under
// test — every call to delete-account in this file uses a real user JWT
// obtained via a genuine sign-in, exactly like the mobile app does.
//
// router_guard_test.dart and delete_account_screen_test.dart cover the
// client-side surface. web/supabase/tests/delete_user_account_test.sql
// covers the SQL function directly with synthetic rows inside a
// BEGIN/ROLLBACK block. This file is the missing middle layer: the deployed
// Edge Function, over HTTP, driven by a real signed JWT — which is what
// real users actually hit.
//
// Every test creates and fully cleans up its own throwaway user(s) via the
// service-role admin API, even on failure, so nothing is left behind in the
// target project.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = String.fromEnvironment('COMETAKE_TEST_SUPABASE_URL');
const _anonKey = String.fromEnvironment('COMETAKE_TEST_SUPABASE_ANON_KEY');
const _serviceRoleKey =
    String.fromEnvironment('COMETAKE_TEST_SUPABASE_SERVICE_ROLE_KEY');

bool get _hasCredentials =>
    _url.isNotEmpty && _anonKey.isNotEmpty && _serviceRoleKey.isNotEmpty;

const _skipReason =
    'live integration test — set COMETAKE_TEST_SUPABASE_URL, '
    'COMETAKE_TEST_SUPABASE_ANON_KEY and COMETAKE_TEST_SUPABASE_SERVICE_ROLE_KEY '
    '(via --dart-define) to run this against a real Supabase project';

/// Thin REST client for the pieces of Supabase this test needs directly —
/// no supabase_flutter client, since that requires plugin bindings the test
/// VM doesn't have and adds session-management behavior this test doesn't
/// want (each user here is used once, deliberately, not persisted).
class _TestSupabase {
  final Dio _dio;
  _TestSupabase() : _dio = Dio(BaseOptions(baseUrl: _url, validateStatus: (_) => true));

  Options _authed(String bearer, {String? apikey}) => Options(headers: {
        'apikey': apikey ?? _anonKey,
        'Authorization': 'Bearer $bearer',
        'Content-Type': 'application/json',
      });

  /// Real signup over /auth/v1/signup — exactly what the app's
  /// SupabaseAuthDatasource.signUp() triggers under the hood.
  Future<String> signUp(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/v1/signup',
      data: {'email': email, 'password': password},
      options: _authed(_anonKey),
    );
    if (res.statusCode != 200) {
      throw StateError('signup failed (${res.statusCode}): ${res.data}');
    }
    return res.data!['id'] as String;
  }

  /// Admin-confirms the email so a real session/JWT can be obtained without
  /// an inbox — the one step in this flow that has no client-side
  /// equivalent (real users click the emailed link instead).
  Future<void> adminConfirmEmail(String userId) async {
    final res = await _dio.put<dynamic>(
      '/auth/v1/admin/users/$userId',
      data: {'email_confirm': true},
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    if (res.statusCode != 200) {
      throw StateError('admin confirm failed (${res.statusCode}): ${res.data}');
    }
  }

  /// Real password sign-in over /auth/v1/token — mints the real JWT this
  /// whole test file exists to exercise delete-account with.
  Future<String> signInGetAccessToken(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/v1/token?grant_type=password',
      data: {'email': email, 'password': password},
      options: _authed(_anonKey),
    );
    if (res.statusCode != 200) {
      throw StateError('sign-in failed (${res.statusCode}): ${res.data}');
    }
    return res.data!['access_token'] as String;
  }

  /// Mirrors the exact upsert SupabaseAuthDatasource.signUp() performs,
  /// using the user's OWN token so RLS is exercised the same way the real
  /// app exercises it.
  Future<void> upsertOwnCoreUserRow({
    required String userToken,
    required String id,
    required String email,
    required String firstName,
  }) async {
    final res = await _dio.post<dynamic>(
      '/rest/v1/core_user',
      data: {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': 'Tester',
        'verified_email': false,
        'is_active': true,
      },
      options: _authed(userToken)
        ..headers!['Prefer'] = 'resolution=merge-duplicates',
    );
    if (res.statusCode! >= 300) {
      throw StateError('core_user upsert failed (${res.statusCode}): ${res.data}');
    }
  }

  /// Seed rows via service role (bypasses RLS — this is test fixture setup,
  /// not the behavior under test; orders in particular aren't
  /// client-insertable in the real app, checkout creates them server-side).
  Future<String> seedAddress(String userId) async {
    final res = await _dio.post<dynamic>(
      '/rest/v1/addresses',
      data: {
        'user_id': userId,
        'full_name': 'Integration Test',
        'phone': '+2348000000000',
        'street': '1 Test Street',
        'city': 'Lagos',
        'state': 'Lagos',
        'postal_code': '100001',
        'country': 'Nigeria',
        'is_default': true,
      },
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey)
        ..headers!['Prefer'] = 'return=representation',
    );
    if (res.statusCode! >= 300) {
      throw StateError('seed address failed (${res.statusCode}): ${res.data}');
    }
    return (res.data as List).first['id'] as String;
  }

  Future<String> seedOrder(String userId, String addressId) async {
    final res = await _dio.post<dynamic>(
      '/rest/v1/orders',
      data: {
        'user_id': userId,
        'address_id': addressId,
        'order_number': 'ORD-ITEST-${DateTime.now().microsecondsSinceEpoch}',
        'subtotal': 1000,
        'shipping_cost': 0,
        'tax': 0,
        'total': 1000,
        'notes': 'integration test order — please ignore',
      },
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey)
        ..headers!['Prefer'] = 'return=representation',
    );
    if (res.statusCode! >= 300) {
      throw StateError('seed order failed (${res.statusCode}): ${res.data}');
    }
    return (res.data as List).first['id'] as String;
  }

  Future<String?> firstProductId() async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/core_products?select=id&limit=1',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    final rows = res.data as List;
    return rows.isEmpty ? null : rows.first['id'] as String;
  }

  Future<void> seedCartItem(String userId, String productId) async {
    await _dio.post<dynamic>(
      '/rest/v1/cart_items',
      data: {'user_id': userId, 'product_id': productId, 'quantity': 1},
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
  }

  Future<void> seedSavedItem(String userId, String productId) async {
    await _dio.post<dynamic>(
      '/rest/v1/core_saveditems',
      data: {'user_id': userId, 'product_id': productId, 'is_fake': false},
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
  }

  Future<Map<String, dynamic>?> getCoreUser(String userId) async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/core_user?id=eq.$userId&select=*',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    final rows = res.data as List;
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first as Map);
  }

  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/orders?id=eq.$orderId&select=*',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    final rows = res.data as List;
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first as Map);
  }

  Future<Map<String, dynamic>?> getAddress(String addressId) async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/addresses?id=eq.$addressId&select=*',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    final rows = res.data as List;
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first as Map);
  }

  Future<int> countCartItems(String userId) async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/cart_items?user_id=eq.$userId&select=id',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    return (res.data as List).length;
  }

  Future<int> countSavedItems(String userId) async {
    final res = await _dio.get<dynamic>(
      '/rest/v1/core_saveditems?user_id=eq.$userId&select=id',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
    return (res.data as List).length;
  }

  /// The actual system under test: the deployed Edge Function, called with
  /// whatever bearer token the caller supplies.
  Future<Response<dynamic>> callDeleteAccount(String? bearer) {
    return _dio.post<dynamic>(
      '/functions/v1/delete-account',
      options: Options(
        headers: {
          'apikey': _anonKey,
          if (bearer != null) 'Authorization': 'Bearer $bearer',
        },
        validateStatus: (_) => true,
      ),
    );
  }

  /// Permanently removes a test user's auth identity — cleanup only, never
  /// exercised as part of the behavior under test.
  Future<void> adminDeleteUser(String userId) async {
    await _dio.delete<dynamic>(
      '/auth/v1/admin/users/$userId',
      options: _authed(_serviceRoleKey, apikey: _serviceRoleKey),
    );
  }
}

void main() {
  final api = _TestSupabase();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  var userCounter = 0;

  // Returns (userId, email, password, accessToken) for a freshly created,
  // admin-confirmed, signed-in throwaway user with a core_user row.
  Future<({String id, String email, String password, String token})>
      createRealUser() async {
    userCounter++;
    final email = 'cometake.itest.$stamp.$userCounter@example.com';
    const password = 'IntegrationTest123!';
    final id = await api.signUp(email, password);
    await api.adminConfirmEmail(id);
    final token = await api.signInGetAccessToken(email, password);
    await api.upsertOwnCoreUserRow(
      userToken: token,
      id: id,
      email: email,
      firstName: 'Integration',
    );
    return (id: id, email: email, password: password, token: token);
  }

  test(
    'real JWT deletion: anonymizes core_user, hard-deletes cart/wishlist, '
    'retains orders/addresses, and revokes the auth identity',
    () async {
      final user = await createRealUser();
      final addressId = await api.seedAddress(user.id);
      final orderId = await api.seedOrder(user.id, addressId);
      final productId = await api.firstProductId();
      if (productId != null) {
        await api.seedCartItem(user.id, productId);
        await api.seedSavedItem(user.id, productId);
      }

      try {
        final res = await api.callDeleteAccount(user.token);
        expect(res.statusCode, 200, reason: 'delete-account response: ${res.data}');
        expect(res.data['success'], true);

        final coreUser = await api.getCoreUser(user.id);
        expect(coreUser, isNotNull, reason: 'core_user must be anonymized, not deleted');
        expect(coreUser!['email'], isNot(user.email));
        expect(coreUser['first_name'], 'Deleted');
        expect(coreUser['is_active'], false);

        final order = await api.getOrder(orderId);
        expect(order, isNotNull,
            reason: 'REGRESSION GUARD: orders must survive account deletion — '
                'this is the exact FK-cascade bug fixed in '
                '20260819120100_normalize_user_fk_targets.sql. If this is '
                'null, that fix has regressed.');
        expect(order!['notes'], isNull, reason: 'order notes must be scrubbed');

        final address = await api.getAddress(addressId);
        expect(address, isNotNull,
            reason: 'REGRESSION GUARD: addresses must survive account '
                'deletion (same FK-cascade class of bug as orders).');

        if (productId != null) {
          expect(await api.countCartItems(user.id), 0);
          expect(await api.countSavedItems(user.id), 0);
        }

        // The auth identity itself must be gone — this is what actually
        // makes the account "deleted" per Apple Guideline 5.1.1(v), not
        // just deactivated. Re-signing in with the same credentials must
        // fail, and a fresh signup with the same email must land on a
        // brand-new id, not resurrect the deleted one.
        final reSignIn = await api.signInGetAccessToken(user.email, user.password)
            .then((_) => true)
            .catchError((_) => false);
        expect(reSignIn, false,
            reason: 'auth.users row must be hard-deleted — sign-in with the '
                'old credentials should no longer succeed');

        final newId = await api.signUp(user.email, user.password);
        expect(newId, isNot(user.id),
            reason: 'signing up again with the same email after deletion must '
                'create a fresh identity, not resurrect the deleted one');
        await api.adminDeleteUser(newId); // clean up the re-signup too
      } finally {
        // Best-effort — if the function already deleted the auth identity
        // this 404s harmlessly.
        await api.adminDeleteUser(user.id);
      }
    },
    skip: _hasCredentials ? false : _skipReason,
  );

  test('rejects a request with no Authorization header at all', () async {
    final res = await api.callDeleteAccount(null);
    expect(res.statusCode, 401);
  }, skip: _hasCredentials ? false : _skipReason);

  test(
    'rejects a malformed/garbage bearer token — fails closed, no fallback '
    'to a privileged path',
    () async {
      final res = await api.callDeleteAccount('not.a.real.jwt.at.all');
      expect(res.statusCode, 401);
      expect(res.data['error'], 'Not authenticated');
    },
    skip: _hasCredentials ? false : _skipReason,
  );

  test(
    'a real JWT only ever deletes its own subject — a second, untouched '
    'user is provably unaffected',
    () async {
      final untouched = await createRealUser();
      final deletee = await createRealUser();

      try {
        final res = await api.callDeleteAccount(deletee.token);
        expect(res.statusCode, 200);

        final untouchedRow = await api.getCoreUser(untouched.id);
        expect(untouchedRow, isNotNull);
        expect(untouchedRow!['email'], untouched.email,
            reason: 'deleting one user must never affect a different, '
                'unrelated user\'s row');
        expect(untouchedRow['is_active'], true);
        expect(untouchedRow['first_name'], isNot('Deleted'));
      } finally {
        await api.adminDeleteUser(deletee.id); // likely already gone; harmless if 404
        await api.adminDeleteUser(untouched.id);
      }
    },
    skip: _hasCredentials ? false : _skipReason,
  );
}
