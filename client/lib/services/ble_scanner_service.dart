import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProximityState {
  immediate,
  near,
  far,
  outOfRange,
}

class CheckpointSighting {
  final String id;
  final int rawRssi;
  final double smoothedRssi;
  final ProximityState proximity;
  final DateTime lastSeen;

  CheckpointSighting({
    required this.id,
    required this.rawRssi,
    required this.smoothedRssi,
    required this.proximity,
    required this.lastSeen,
  });

  CheckpointSighting copyWith({
    int? rawRssi,
    double? smoothedRssi,
    ProximityState? proximity,
    DateTime? lastSeen,
  }) {
    return CheckpointSighting(
      id: id,
      rawRssi: rawRssi ?? this.rawRssi,
      smoothedRssi: smoothedRssi ?? this.smoothedRssi,
      proximity: proximity ?? this.proximity,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class NearestBeaconNotifier extends StateNotifier<Map<String, CheckpointSighting>> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  NearestBeaconNotifier() : super({});

  bool get _supportsNativeBle =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void startScanning() async {
    if (!_supportsNativeBle) return;

    // Check if bluetooth is on
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        _processScanResults(results);
      });
      // Start scanning continuously
      FlutterBluePlus.startScan(
        withKeywords: ["TNEPIC_CP"],
        continuousUpdates: true,
      );
    }
  }

  void stopScanning() {
    if (!_supportsNativeBle) return;

    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }

  void _processScanResults(List<ScanResult> results) {
    final now = DateTime.now();
    Map<String, CheckpointSighting> newState = Map.from(state);

    for (ScanResult r in results) {
      final name = r.advertisementData.advName;
      if (!name.startsWith('TNEPIC_CP_')) continue;

      final rssi = r.rssi;
      final existing = newState[name];
      
      // Exponential Moving Average filter (alpha = 0.3)
      double smoothedRssi = existing != null 
          ? (rssi * 0.3) + (existing.smoothedRssi * 0.7) 
          : rssi.toDouble();

      newState[name] = CheckpointSighting(
        id: name,
        rawRssi: rssi,
        smoothedRssi: smoothedRssi,
        proximity: _mapToProximity(smoothedRssi),
        lastSeen: now,
      );
    }

    state = newState;
  }

  ProximityState _mapToProximity(double rssi) {
    if (rssi > -55) return ProximityState.immediate;
    if (rssi > -70) return ProximityState.near;
    if (rssi > -85) return ProximityState.far;
    return ProximityState.outOfRange;
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }
}

final nearestBeaconProvider = StateNotifierProvider<NearestBeaconNotifier, Map<String, CheckpointSighting>>((ref) {
  final notifier = NearestBeaconNotifier();
  // Start scanning immediately when provider is first read
  notifier.startScanning();
  return notifier;
});
