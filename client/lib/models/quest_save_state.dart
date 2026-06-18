import 'package:hive/hive.dart';

part 'quest_save_state.g.dart';

@HiveType(typeId: 0)
class QuestSaveState extends HiveObject {
  @HiveField(0)
  final String questId;

  @HiveField(1)
  final String lastCheckpointId;

  @HiveField(2)
  final int lastCheckpointIndex;

  @HiveField(3)
  final int points;

  @HiveField(4)
  final int streakCount;

  @HiveField(5)
  final List<String> collectedNodeIds;

  @HiveField(6)
  final DateTime savedAt;

  QuestSaveState({
    required this.questId,
    required this.lastCheckpointId,
    required this.lastCheckpointIndex,
    required this.points,
    required this.streakCount,
    required this.collectedNodeIds,
    required this.savedAt,
  });
}
