import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TiltService {
  TiltService._();
  static final TiltService instance = TiltService._();

  final _tiltController = StreamController<double>.broadcast();
  Stream<double> get tiltStream => _tiltController.stream;

  StreamSubscription? _accelerometerSubscription;
  double _smoothedTilt = 0.0;
  final double _alpha = 0.1; // Low-pass filter smoothing factor

  void startListening() {
    _accelerometerSubscription?.cancel();
    
    _accelerometerSubscription = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((AccelerometerEvent event) {
      final double x = event.x;
      final double y = event.y;
      final double z = event.z;

      final double magnitude = sqrt(x * x + y * y + z * z);
      if (magnitude < 0.1) return;

      // Normalize Y component
      final double normalizedY = y / magnitude;
      
      // Map tilt: 0.0 means vertical (screen facing user), 1.0 means parallel to floor (looking straight down)
      // Since Y component is maximum when vertical and minimum when flat, tilt = 1.0 - normalizedY.abs()
      final double rawTilt = (1.0 - normalizedY.abs()).clamp(0.0, 1.0);

      // Apply low-pass filter
      _smoothedTilt = _alpha * rawTilt + (1 - _alpha) * _smoothedTilt;

      _tiltController.add(_smoothedTilt);
    }, onError: (error) {
      debugPrint("[TiltService] Accelerometer error: $error");
    });
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}
