import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';
import '../services/ble_scanner_service.dart';
import '../services/tilt_service.dart';
import '../models/quest_save_state.dart';
import '../widgets/ar_hud_overlay.dart';

enum CheckpointPhase {
  dormant,
  approaching,
  ready,
  dwelling,
  saving,
  confirmed,
}

class ARCheckpointScreen extends ConsumerStatefulWidget {
  final QuestSaveState? resumeState;

  const ARCheckpointScreen({Key? key, this.resumeState}) : super(key: key);

  @override
  ConsumerState<ARCheckpointScreen> createState() => _ARCheckpointScreenState();
}

class _ARCheckpointScreenState extends ConsumerState<ARCheckpointScreen>
    with SingleTickerProviderStateMixin {
  ArCoreController? arCoreController;
  Map<String, ArCoreNode> popups = {};
  Map<String, CheckpointPhase> checkpointStates = {};
  bool _tiltServiceStarted = false;

  Timer? _dwellTimer;
  String? _dwellingCheckpointId;

  // AR nodes
  ArCoreNode? roadNode;

  @override
  void initState() {
    super.initState();
    // Initialize saved states if resuming
    if (widget.resumeState != null) {
      // E.g., setup already confirmed checkpoints
      for (int i = 1; i <= widget.resumeState!.lastCheckpointIndex; i++) {
        checkpointStates['TNEPIC_CP_$i'] = CheckpointPhase.confirmed;
      }
    }

    if (_supportsNativeArCore) {
      TiltService().start();
      TiltService().addListener(_onTiltChanged);
      _tiltServiceStarted = true;
    }
  }

  bool get _supportsNativeArCore =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _onTiltChanged() {
    // Opacity control logic can be handled in the AR HUD Overlay
    setState(() {});
  }

  @override
  void dispose() {
    if (_tiltServiceStarted) {
      TiltService().removeListener(_onTiltChanged);
      TiltService().stop();
    }
    arCoreController?.dispose();
    _dwellTimer?.cancel();
    super.dispose();
  }

  Future<void> _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;

    // 1. Copy .imgdb to temp dir
    final ByteData data = await rootBundle.load('assets/image_database.imgdb');
    final Directory tempDir = await getTemporaryDirectory();
    final File dbFile = File('${tempDir.path}/image_database.imgdb');
    await dbFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );

    // 2. Load augmented image database
    await arCoreController?.loadAugmentedImagesDatabase(
      bytes: dbFile.readAsBytesSync(),
    );

    // 3. Register onTrackingImage callback
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
  }

  void _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    // Determine which checkpoint based on image name
    final state = augmentedImage.trackingMethod;
    final index = augmentedImage.index;

    // Check mapping based on index or name. Assuming name contains CP info.
    // E.g., marker1.jpg -> TNEPIC_CP_1
    String cpId = 'TNEPIC_CP_${index + 1}'; // Simple mapping

    if (state == TrackingMethod.FULL_TRACKING) {
      if (!popups.containsKey(cpId)) {
        _spawnPopup(augmentedImage, cpId);
      }
    }
  }

  void _spawnPopup(ArCoreAugmentedImage image, String cpId) {
    // Create base anchor + 30cm offset
    final position = vector.Vector3(
      image.centerPose.translation.x,
      image.centerPose.translation.y + 0.3,
      image.centerPose.translation.z,
    );

    // Cylinder icon node
    final material = ArCoreMaterial(color: AppColors.gold, metallic: 1.0);
    final cylinder = ArCoreCylinder(
      materials: [material],
      radius: 0.05,
      height: 0.01,
    );

    final node = ArCoreNode(
      shape: cylinder,
      position: position,
      rotation: vector.Vector4(0, 0, 0, 1),
      name: '${cpId}_popup',
    );

    arCoreController?.addArCoreNodeToAugmentedImage(node, image.index);
    popups[cpId] = node;

    // Transition state
    _updateCheckpointState(cpId);
  }

  void _updateCheckpointState(String cpId) {
    final proximityState =
        ref.read(nearestBeaconProvider)[cpId]?.proximity ??
        ProximityState.outOfRange;
    final currentPhase = checkpointStates[cpId] ?? CheckpointPhase.dormant;

    if (currentPhase == CheckpointPhase.confirmed) return;

    if (proximityState == ProximityState.immediate &&
        popups.containsKey(cpId)) {
      setState(() {
        checkpointStates[cpId] = CheckpointPhase.ready;
      });
      _startDwellTimer(cpId);
    } else if (proximityState == ProximityState.near ||
        proximityState == ProximityState.far) {
      setState(() {
        checkpointStates[cpId] = CheckpointPhase.approaching;
      });
      _cancelDwellTimer();
    }
  }

  void _startDwellTimer(String cpId) {
    if (_dwellingCheckpointId == cpId) return;

    setState(() {
      _dwellingCheckpointId = cpId;
      checkpointStates[cpId] = CheckpointPhase.dwelling;
    });

    _dwellTimer?.cancel();
    _dwellTimer = Timer(const Duration(milliseconds: 1500), () {
      _executeSave(cpId);
    });
  }

  void _cancelDwellTimer() {
    _dwellTimer?.cancel();
    if (_dwellingCheckpointId != null &&
        checkpointStates[_dwellingCheckpointId] != CheckpointPhase.confirmed) {
      setState(() {
        checkpointStates[_dwellingCheckpointId!] = CheckpointPhase.ready;
        _dwellingCheckpointId = null;
      });
    }
  }

  Future<void> _executeSave(String cpId) async {
    setState(() {
      checkpointStates[cpId] = CheckpointPhase.saving;
    });

    // Extract index from ID e.g., TNEPIC_CP_1
    int cpIndex = int.tryParse(cpId.split('_').last) ?? 1;

    final state = QuestSaveState(
      questId: 'demo_quest',
      lastCheckpointId: cpId,
      lastCheckpointIndex: cpIndex,
      points: (widget.resumeState?.points ?? 0) + 100, // example
      streakCount: (widget.resumeState?.streakCount ?? 0) + 1,
      collectedNodeIds: widget.resumeState?.collectedNodeIds ?? [],
      savedAt: DateTime.now(),
    );

    final box = Hive.box<QuestSaveState>('quest_saves');
    await box.put('demo_quest', state);

    // Flash effect could be done here or in ARHUDOverlay

    setState(() {
      checkpointStates[cpId] = CheckpointPhase.confirmed;
      _dwellingCheckpointId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsNativeArCore) {
      return _buildUnsupportedPlatform(context);
    }

    // Listen to BLE changes to update state machine
    ref.listen<Map<String, CheckpointSighting>>(nearestBeaconProvider, (
      previous,
      next,
    ) {
      next.forEach((cpId, sighting) {
        if (sighting.proximity == ProximityState.immediate) {
          _updateCheckpointState(cpId);
        } else if (sighting.proximity == ProximityState.near ||
            sighting.proximity == ProximityState.far) {
          if (checkpointStates[cpId] != CheckpointPhase.confirmed &&
              checkpointStates[cpId] != CheckpointPhase.dwelling) {
            setState(() {
              checkpointStates[cpId] = CheckpointPhase.approaching;
            });
          }
        }
      });
    });

    final tilt = TiltService().tilt;
    final roadOpacity = _calculateRoadOpacity(tilt);

    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableUpdateListener: true,
            type: ArCoreViewType.AUGMENTEDIMAGES,
          ),
          // Road Overlay Placeholder (managed by opacity)
          IgnorePointer(
            child: Opacity(
              opacity: roadOpacity,
              child: Container(
                color: AppColors.gold.withOpacity(0.1), // simple representation
              ),
            ),
          ),
          ARHUDOverlay(
            checkpointStates: checkpointStates,
            onForceSave: (cpId) => _executeSave(cpId),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedPlatform(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: AppColors.gold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'AR checkpoints need Android ARCore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This browser/desktop build can plan trips, but the native checkpoint camera view is only available on Android devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateRoadOpacity(double tilt) {
    if (tilt < 0.15) return 0.0;
    if (tilt >= 0.15 && tilt <= 0.80) {
      // Smoothstep 0.20 to 0.40 up
      if (tilt < 0.20) return 0.0;
      if (tilt < 0.40) return (tilt - 0.20) / 0.20;
      // Smoothstep 0.80 to 0.65 down (meaning from 0.65 to 0.80 it fades out to 0.5)
      if (tilt > 0.65) {
        return 1.0 - ((tilt - 0.65) / 0.15) * 0.5;
      }
      return 1.0;
    }
    return 0.5; // Above 0.80
  }
}
