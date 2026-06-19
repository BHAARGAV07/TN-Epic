import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_colors.dart';
import '../models/destination.dart';
import '../models/quest_node.dart';
import '../models/vector3.dart';
import '../services/route_manager.dart';
import '../state/app_state.dart';
import '../widgets/ar_viewport.dart';
import '../widgets/ar_premium_hud.dart';
import '../widgets/ar_reward_notification.dart';

class RoadViewScreen extends StatefulWidget {
  final LatLng startLocation;
  final List<Destination> destinations;

  const RoadViewScreen({
    super.key,
    required this.startLocation,
    required this.destinations,
  });

  @override
  State<RoadViewScreen> createState() => _RoadViewScreenState();
}

class _RoadViewScreenState extends State<RoadViewScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  // VIO Cartesian coordinates
  // User position at eye level (Z = 0) standing on ground, looking down at corridor (Z = -1.6)
  Vector3 _userPosition = const Vector3(0.0, 0.0, 0.0);
  final List<Vector3> _routeWaypoints = RouteManager.getCorridorRoute();
  final List<QuestNode> _questNodes = RouteManager.getCorridorQuestNodes();

  // Floor scanning simulator
  bool _isFloorDetected = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  bool _isLoading = true;
  String _loadingStatus = "Initializing Camera & Gyro bindings...";

  @override
  void initState() {
    super.initState();

    _initCamera();
    _startFloorScanning();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _loadingStatus = "No cameras found";
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeCameraFuture = _cameraController!.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Camera Init Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startFloorScanning() {
    // Simulate floor scan radar
    _scanTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _scanProgress += 0.04;
        if (_scanProgress >= 1.0) {
          _isFloorDetected = true;
          _scanTimer?.cancel();
        }
      });
    });
  }

  void _onCollectNode(QuestNode node) {
    setState(() {
      // Update global game scores
      if (node.type == 'coin') {
        AppState.totalTokens += node.value;
        AppState.dharmaScore += (node.value * 1.5).round();
      } else if (node.type == 'save_point') {
        AppState.dharmaScore += 120;
      } else if (node.type == 'beacon') {
        AppState.totalTokens += node.value;
        AppState.dharmaScore += (node.value * 2.0).round();
        AppState.tripsCompleted += 1;
      }
    });
  }

  void _onLocationChanged(Vector3 newPosition) {
    setState(() {
      _userPosition = newPosition;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 24),
              Text(
                _loadingStatus,
                style: GoogleFonts.inter(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Full-screen Camera Stream
          Positioned.fill(
            child: FutureBuilder<void>(
              future: _initializeCameraFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized) {
                  return CameraPreview(_cameraController!);
                }
                return Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.camera_enhance,
                      color: AppColors.secondary,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
          ),

          // LAYER 2: AR Viewport Core Canvas overlay
          // CRITICAL: This owns the golden corridor and is kept below all UI overlays
          // The golden path is rendered at 100% opacity and NEVER covered
          Positioned.fill(
            child: RepaintBoundary(
              child: ArViewport(
                userPosition: _userPosition,
                roadWaypoints: _routeWaypoints,
                questNodes: _questNodes,
                onCollectQuestNode: _onCollectNode,
                onLocationChanged: _onLocationChanged,
                isFloorDetected: _isFloorDetected,
                scanProgress: _scanProgress,
              ),
            ),
          ),

          // LAYER 4: Premium UI Overlays (never blocks path)
          // Using proper z-order and IgnorePointer to ensure path visibility
          ARPremiumHUD(
            isFloorDetected: _isFloorDetected,
            isSimulatingWalk: false,
            scanProgress: _scanProgress,
            userPosition: _userPosition,
            roadWaypoints: _routeWaypoints,
            collectedCoins: AppState.totalTokens,
            dharmaScore: AppState.dharmaScore,
            checkpointsCollected: _questNodes
                .where((n) => n.type == 'save_point' && n.isCollected)
                .length,
            onStartSimulation: () {
              setState(() {
                // Start simulation is handled by ArViewport internally
              });
            },
          ),

          // Reward notifications (non-blocking, above HUD)
          RewardNotificationManager(collectedNodes: _questNodes),
        ],
      ),
    );
  }
}
