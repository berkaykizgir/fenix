import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Provides network connectivity status.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get connectionStream {
    return connectivity.onConnectivityChanged.map((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      debugPrint('📡 Network: ${isConnected ? "ONLINE" : "OFFLINE"}');
      return isConnected;
    });
  }
}
