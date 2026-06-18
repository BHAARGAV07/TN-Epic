import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ProximityBucket {
  outOfRange,
  far,
  near,
  immediate,
}

class BleService {
  BleService._();
  static final BleService instance = BleService._();

  final _scanResultsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get scanResultsStream => _scanResultsController.stream;

  final Map<String, double> _smoothedRssiMap = {};
  final double _alpha = 0.3; // smoothing factor for EMA

  bool _isScanning = false;
  StreamSubscription? _scanSubscription;

  void startScanning() async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      if (await FlutterBluePlus.isSupported == false) {
        debugPrint("[BLE] Bluetooth is not supported on this device");
        return;
      }

      // Wait for Bluetooth to be on
      await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

      // Start scan with TNEPIC_CP keywords filtering at hardware level
      await FlutterBluePlus.startScan(
        withKeywords: ['TNEPIC_CP'],
        continuousUpdates: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final String name = result.device.platformName.isNotEmpty 
              ? result.device.platformName 
              : result.advertisementData.advName;
          
          if (name.startsWith('TNEPIC_CP')) {
            final int rawRssi = result.rssi;
            final double previousSmoothed = _smoothedRssiMap[name] ?? rawRssi.toDouble();
            final double smoothed = _alpha * rawRssi + (1 - _alpha) * previousSmoothed;
            _smoothedRssiMap[name] = smoothed;

            final proximity = _mapRssiToProximity(smoothed);
            
            _scanResultsController.add({
              'id': name,
              'rawRssi': rawRssi,
              'smoothedRssi': smoothed,
              'proximity': proximity,
            });
          }
        }
      });
    } catch (e) {
      debugPrint("[BLE] Scan start failed: $e");
      _isScanning = false;
    }
  }

  void stopScanning() async {
    if (!_isScanning) return;
    _isScanning = false;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint("[BLE] Stop scan failed: $e");
    }
  }

  ProximityBucket _mapRssiToProximity(double rssi) {
    // Calibrated thresholds for college corridor:
    // immediate above -55 dBm
    // near above -70 dBm
    // far above -85 dBm
    // out-of-range below -85 dBm
    if (rssi > -55) {
      return ProximityBucket.immediate;
    } else if (rssi > -70) {
      return ProximityBucket.near;
    } else if (rssi > -85) {
      return ProximityBucket.far;
    } else {
      return ProximityBucket.outOfRange;
    }
  }
}
