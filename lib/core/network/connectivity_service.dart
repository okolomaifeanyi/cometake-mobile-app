import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
  name: 'connectivityServiceProvider',
);

final isConnectedProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).onConnectivityChanged,
  name: 'isConnectedProvider',
);

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => _connectivity
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
