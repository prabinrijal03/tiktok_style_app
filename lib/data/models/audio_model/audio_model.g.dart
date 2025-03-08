// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioModelAdapter extends TypeAdapter<AudioModel> {
  @override
  final int typeId = 1;

  @override
  AudioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioModel(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      audioUrl: fields[3] as String,
      coverUrl: fields[4] as String,
      duration: fields[5] as int,
      usageCount: fields[6] as int,
      isFavorite: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AudioModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.audioUrl)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.usageCount)
      ..writeByte(7)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
