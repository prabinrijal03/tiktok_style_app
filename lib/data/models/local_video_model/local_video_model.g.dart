// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalVideoModelAdapter extends TypeAdapter<LocalVideoModel> {
  @override
  final int typeId = 0;

  @override
  LocalVideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalVideoModel(
      id: fields[0] as String,
      videoPath: fields[1] as String,
      thumbnailPath: fields[2] as String,
      description: fields[3] as String,
      username: fields[4] as String,
      audioName: fields[5] as String?,
      audioId: fields[11] as String?,
      likes: fields[6] as int,
      comments: fields[7] as int,
      shares: fields[8] as int,
      isLiked: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalVideoModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoPath)
      ..writeByte(2)
      ..write(obj.thumbnailPath)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.audioName)
      ..writeByte(6)
      ..write(obj.likes)
      ..writeByte(7)
      ..write(obj.comments)
      ..writeByte(8)
      ..write(obj.shares)
      ..writeByte(9)
      ..write(obj.isLiked)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.audioId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalVideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
