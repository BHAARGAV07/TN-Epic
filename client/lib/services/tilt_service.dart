import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TiltService extends ChangeNotifier {
  static final TiltService _instance = TiltService._internal();
  factory TiltService() => _instance;
  
  TiltService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  
  double _smoothedTilt = 0.0;
  double get tilt => _smoothedTilt;

  void start() {
    if (_subscription != null) return;
    
    _subscription = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((AccelerometerEvent event) {
      
      // Calculate magnitude of the gravity vector
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // Normalize Y component to get value between -1.0 and 1.0
      // When Y is equal to magnitude, phone is perfectly upright (or upside down depending on sign)
      final normalizedY = magnitude > 0 ? (event.y / magnitude) : 0.0;
      
      // Map to 0.0 (upright/flat) to 1.0 (facing floor)
      // If Y is positive, phone is upright.
      // We need to map such that 0.0 means screen facing user vertically, 1.0 means screen facing floor.
      // Depending on coordinate system, Y ~ 9.8 when upright, Z ~ 9.8 when flat face up.
      // Let's use standard Android coordinate system:
      // Upright (portrait): Y ~ 9.8
      // Flat face up: Z ~ 9.8
      // Flat face down: Z ~ -9.8
      // Upside down: Y ~ -9.8
      // Tilt = facing floor. When facing floor, Z approaches -9.8.
      // Actually the plan says: "0.0 means the phone screen is facing the user vertically and 1.0 means the screen is facing the floor."
      // Let's use Z component instead for floor facing detection.
      // Upright: Z = 0
      // Face up: Z = 9.8
      // Face down (floor): Z = -9.8
      // If we use Y: Upright Y = 9.8, Face floor Y = 0. 
      // Plan explicitly says: "Normalize the Y component by dividing it by the magnitude to get a value between -1 and +1. Map this to a tilt value between 0.0 and 1.0 where 0.0 means the phone screen is facing the user vertically and 1.0 means the screen is facing the floor."
      // Upright: Y = 9.8 -> normalizedY = 1.0. 
      // Face floor: Y = 0.0 -> normalizedY = 0.0. 
      // So tilt = 1.0 - normalizedY
      
      double rawTilt = (1.0 - normalizedY).clamp(0.0, 1.0);

      // Low-pass filter (alpha = 0.1)
      _smoothedTilt = (_smoothedTilt * 0.9) + (rawTilt * 0.1);
      
      notifyListeners();
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
