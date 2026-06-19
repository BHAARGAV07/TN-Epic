import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../services/ble_scanner_service.dart';
import '../screens/ar_checkpoint_screen.dart'; // For CheckpointPhase enum

class ARHUDOverlay extends ConsumerWidget {
  final Map<String, CheckpointPhase> checkpointStates;
  final Function(String) onForceSave;

  const ARHUDOverlay({
    Key? key,
    required this.checkpointStates,
    required this.onForceSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beacons = ref.watch(nearestBeaconProvider);

    // Find nearest approaching/ready/dwelling beacon
    String? nearestActiveId;
    CheckpointSighting? nearestSighting;

    beacons.forEach((id, sighting) {
      final phase = checkpointStates[id] ?? CheckpointPhase.dormant;
      if (phase != CheckpointPhase.confirmed && phase != CheckpointPhase.dormant) {
        if (nearestSighting == null || sighting.smoothedRssi > nearestSighting!.smoothedRssi) {
          nearestSighting = sighting;
          nearestActiveId = id;
        }
      }
    });

    return Stack(
      children: [
        // Top Banner for Approaching
        if (nearestActiveId != null && checkpointStates[nearestActiveId] == CheckpointPhase.approaching)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    "Save Point Nearby",
                    style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Keep walking forward",
                    style: TextStyle(color: AppColors.text, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        // Fallback indicator when immediate but not tracking
        if (nearestActiveId != null && 
            beacons[nearestActiveId]?.proximity == ProximityState.immediate && 
            checkpointStates[nearestActiveId] != CheckpointPhase.ready &&
            checkpointStates[nearestActiveId] != CheckpointPhase.dwelling &&
            checkpointStates[nearestActiveId] != CheckpointPhase.saving &&
            checkpointStates[nearestActiveId] != CheckpointPhase.confirmed)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  "Point camera toward the checkpoint marker",
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Full screen gold flash when saving
        if (checkpointStates.values.contains(CheckpointPhase.saving))
          IgnorePointer(
            child: Container(
              color: AppColors.gold.withOpacity(0.5),
            ),
          ),

        // Debug/Fallback Manual Save Button
        if (nearestActiveId != null && beacons[nearestActiveId]?.proximity == ProximityState.immediate)
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppColors.gold,
              onPressed: () => onForceSave(nearestActiveId!),
              child: Icon(Icons.save, color: AppColors.background),
              tooltip: 'Manual Save Fallback',
            ),
          ),
      ],
    );
  }
}
