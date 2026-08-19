import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically random raw nonce for the Sign in with
/// Apple flow. Supabase's signInWithIdToken needs the RAW nonce; Apple's
/// native SDK needs the SHA-256 HASH of that same nonce — this asymmetry
/// is how Supabase verifies the ID token actually came from a request
/// this app made, not a replayed one.
String generateRawNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

String sha256OfNonce(String rawNonce) {
  return sha256.convert(utf8.encode(rawNonce)).toString();
}

/// Apple only returns the user's name on the FIRST authorization ever
/// granted to this app — every later sign-in omits it entirely. Returns
/// null when there is nothing to persist (i.e. every login after the
/// first), so the caller can skip the update call rather than overwriting
/// previously-saved names with blanks.
Map<String, dynamic>? buildAppleFirstLoginUpdate({
  String? givenName,
  String? familyName,
}) {
  final update = <String, dynamic>{};
  if (givenName != null && givenName.trim().isNotEmpty) {
    update['first_name'] = givenName.trim();
  }
  if (familyName != null && familyName.trim().isNotEmpty) {
    update['last_name'] = familyName.trim();
  }
  return update.isEmpty ? null : update;
}
