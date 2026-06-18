import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quest_save_state.dart';
import '../services/ble_service.dart';

enum CheckpointPhase {
  dormant,
  approaching,
  ready,
  dwelling,
  saving,
  confirmed,
}

// Map BLE beacon IDs to QuestNode IDs
String mapBeaconIdToNodeId(String beaconId) {
  if (beaconId == 'TNEPIC_CP_1') return 'sp_1';
  if (beaconId == 'TNEPIC_CP_2') return 'sp_2';
  if (beaconId == 'TNEPIC_CP_3') return 'beacon_1';
  return beaconId;
}

String mapNodeIdToBeaconId(String nodeId) {
  if (nodeId == 'sp_1') return 'TNEPIC_CP_1';
  if (nodeId == 'sp_2') return 'TNEPIC_CP_2';
  if (nodeId == 'beacon_1') return 'TNEPIC_CP_3';
  return nodeId;
}

// 1. BLE Sighting Stream Provider
final bleSightingStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return BleService.instance.scanResultsStream;
});

// Nearest Beacon Model
class BeaconSighting {
  final String id;
  final double rawRssi;
  final double smoothedRssi;
  final ProximityBucket proximity;
  final DateTime lastSighted;

  BeaconSighting({
    required this.id,
    required this.rawRssi,
    required this.smoothedRssi,
    required this.proximity,
    required this.lastSighted,
  });
}

// 2. Nearest Beacon Provider
final nearestBeaconProvider = StateNotifierProvider<NearestBeaconNotifier, BeaconSighting?>((ref) {
  final sightingStream = ref.watch(bleSightingStreamProvider);
  final notifier = NearestBeaconNotifier();
  
  sightingStream.whenData((sighting) {
    notifier.updateSighting(sighting);
  });
  
  return notifier;
});

class NearestBeaconNotifier extends StateNotifier<BeaconSighting?> {
  NearestBeaconNotifier() : super(null);

  void updateSighting(Map<String, dynamic> data) {
    final String id = data['id'];
    final double rawRssi = (data['rawRssi'] as num).toDouble();
    final double smoothedRssi = (data['smoothedRssi'] as num).toDouble();
    final ProximityBucket proximity = data['proximity'];
    
    // Only update if it's closer or if it's the current nearest beacon updating
    if (state == null || id == state!.id || smoothedRssi > state!.smoothedRssi) {
      state = BeaconSighting(
        id: id,
        rawRssi: rawRssi,
        smoothedRssi: smoothedRssi,
        proximity: proximity,
        lastSighted: DateTime.now(),
      );
    }
  }

  void clear() {
    state = null;
  }
}

// 3. Checkpoint Phase Provider (Family)
final checkpointPhaseProvider = StateNotifierProvider.family<CheckpointPhaseNotifier, CheckpointPhase, String>((ref, nodeId) {
  return CheckpointPhaseNotifier(nodeId, ref);
});

class CheckpointPhaseNotifier extends StateNotifier<CheckpointPhase> {
  final String nodeId;
  final Ref ref;

  CheckpointPhaseNotifier(this.nodeId, this.ref) : super(CheckpointPhase.dormant) {
    // Listen to nearest beacon and update phase accordingly
    ref.listen<BeaconSighting?>(nearestBeaconProvider, (prev, next) {
      if (state == CheckpointPhase.confirmed) return; // Terminal state

      final String beaconId = mapNodeIdToBeaconId(nodeId);
      if (next != null && next.id == beaconId) {
        if (next.proximity == ProximityBucket.immediate) {
          if (state == CheckpointPhase.dormant || state == CheckpointPhase.approaching) {
            state = CheckpointPhase.ready;
          }
        } else if (next.proximity == ProximityBucket.near || next.proximity == ProximityBucket.far) {
          if (state == CheckpointPhase.dormant || state == CheckpointPhase.ready) {
            state = CheckpointPhase.approaching;
          }
        } else {
          state = CheckpointPhase.dormant;
        }
      } else if (next == null || next.id != beaconId) {
        if (state != CheckpointPhase.confirmed) {
          state = CheckpointPhase.dormant;
        }
      }
    });
  }

  void setPhase(CheckpointPhase phase) {
    state = phase;
  }
}

// 4. Quest Session State Model
class QuestSessionState {
  final String questId;
  final int points;
  final int streakCount;
  final Set<String> collectedNodeIds;
  final Set<String> confirmedCheckpointIds;
  final String? lastSavedCheckpointId;
  final int lastSavedCheckpointIndex;
  final DateTime? savedAt;
  final bool isResumed;

  QuestSessionState({
    required this.questId,
    this.points = 0,
    this.streakCount = 0,
    required this.collectedNodeIds,
    required this.confirmedCheckpointIds,
    this.lastSavedCheckpointId,
    this.lastSavedCheckpointIndex = -1,
    this.savedAt,
    this.isResumed = false,
  });

  QuestSessionState copyWith({
    String? questId,
    int? points,
    int? streakCount,
    Set<String>? collectedNodeIds,
    Set<String>? confirmedCheckpointIds,
    String? lastSavedCheckpointId,
    int? lastSavedCheckpointIndex,
    DateTime? savedAt,
    bool? isResumed,
  }) {
    return QuestSessionState(
      questId: questId ?? this.questId,
      points: points ?? this.points,
      streakCount: streakCount ?? this.streakCount,
      collectedNodeIds: collectedNodeIds ?? this.collectedNodeIds,
      confirmedCheckpointIds: confirmedCheckpointIds ?? this.confirmedCheckpointIds,
      lastSavedCheckpointId: lastSavedCheckpointId ?? this.lastSavedCheckpointId,
      lastSavedCheckpointIndex: lastSavedCheckpointIndex ?? this.lastSavedCheckpointIndex,
      savedAt: savedAt ?? this.savedAt,
      isResumed: isResumed ?? this.isResumed,
    );
  }
}

// 5. Quest Session State Provider
final questSessionProvider = StateNotifierProvider<QuestSessionNotifier, QuestSessionState>((ref) {
  return QuestSessionNotifier(ref);
});

class QuestSessionNotifier extends StateNotifier<QuestSessionState> {
  final Ref ref;

  QuestSessionNotifier(this.ref) : super(QuestSessionState(questId: 'heritage_corridor_quest', collectedNodeIds: {}, confirmedCheckpointIds: {}));

  void initNewSession() {
    state = QuestSessionState(
      questId: 'heritage_corridor_quest',
      collectedNodeIds: {},
      confirmedCheckpointIds: {},
    );
  }

  void loadResumedSession(QuestSaveState save) {
    state = QuestSessionState(
      questId: save.questId,
      points: save.points,
      streakCount: save.streakCount,
      collectedNodeIds: save.collectedNodeIds.toSet(),
      confirmedCheckpointIds: {save.lastCheckpointId},
      lastSavedCheckpointId: save.lastCheckpointId,
      lastSavedCheckpointIndex: save.lastCheckpointIndex,
      savedAt: save.savedAt,
      isResumed: true,
    );

    // Confirmed up to the checkpoint index
    if (save.lastCheckpointIndex >= 0) {
      ref.read(checkpointPhaseProvider('sp_1').notifier).setPhase(CheckpointPhase.confirmed);
    }
    if (save.lastCheckpointIndex >= 1) {
      ref.read(checkpointPhaseProvider('sp_2').notifier).setPhase(CheckpointPhase.confirmed);
    }
    if (save.lastCheckpointIndex >= 2) {
      ref.read(checkpointPhaseProvider('beacon_1').notifier).setPhase(CheckpointPhase.confirmed);
    }
  }

  void collectNode(String nodeId, int value) {
    if (state.collectedNodeIds.contains(nodeId)) return;

    final updatedCollected = Set<String>.from(state.collectedNodeIds)..add(nodeId);
    state = state.copyWith(
      points: state.points + value,
      collectedNodeIds: updatedCollected,
    );
  }

  Future<void> saveCheckpoint(String nodeId, int index) async {
    if (state.confirmedCheckpointIds.contains(nodeId)) return;

    ref.read(checkpointPhaseProvider(nodeId).notifier).setPhase(CheckpointPhase.confirmed);

    int saveBonus = (nodeId == 'beacon_1') ? 200 : 120;
    int newStreak = state.streakCount + 1;

    final updatedConfirmed = Set<String>.from(state.confirmedCheckpointIds)..add(nodeId);
    final updatedCollected = Set<String>.from(state.collectedNodeIds)..add(nodeId);

    state = state.copyWith(
      points: state.points + saveBonus,
      streakCount: newStreak,
      confirmedCheckpointIds: updatedConfirmed,
      collectedNodeIds: updatedCollected,
      lastSavedCheckpointId: nodeId,
      lastSavedCheckpointIndex: index,
      savedAt: DateTime.now(),
    );

    final box = Hive.box<QuestSaveState>('quest_saves');
    final saveState = QuestSaveState(
      questId: state.questId,
      lastCheckpointId: nodeId,
      lastCheckpointIndex: index,
      points: state.points,
      streakCount: state.streakCount,
      collectedNodeIds: state.collectedNodeIds.toList(),
      savedAt: state.savedAt!,
    );
    await box.put(state.questId, saveState);
    
    debugPrint("[Storage] Atomically saved state to Hive: points=${state.points}, streak=$newStreak, checkpoint=$nodeId");
  }
}
