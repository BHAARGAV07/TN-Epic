// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_save_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestSaveStateAdapter extends TypeAdapter<QuestSaveState> {
  @override
  final int typeId = 0;

  @override
  QuestSaveState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestSaveState(
      questId: fields[0] as String,
      lastCheckpointId: fields[1] as String,
      lastCheckpointIndex: fields[2] as int,
      points: fields[3] as int,
      streakCount: fields[4] as int,
      collectedNodeIds: (fields[5] as List).cast<String>(),
      savedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuestSaveState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.questId)
      ..writeByte(1)
      ..write(obj.lastCheckpointId)
      ..writeByte(2)
      ..write(obj.lastCheckpointIndex)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.streakCount)
      ..writeByte(5)
      ..write(obj.collectedNodeIds)
      ..writeByte(6)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestSaveStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
