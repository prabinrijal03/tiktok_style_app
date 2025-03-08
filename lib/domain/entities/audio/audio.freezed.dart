// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Audio _$AudioFromJson(Map<String, dynamic> json) {
  return _Audio.fromJson(json);
}

/// @nodoc
mixin _$Audio {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  String get coverUrl => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Serializes this Audio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioCopyWith<Audio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioCopyWith<$Res> {
  factory $AudioCopyWith(Audio value, $Res Function(Audio) then) =
      _$AudioCopyWithImpl<$Res, Audio>;
  @useResult
  $Res call(
      {String id,
      String title,
      String artist,
      String audioUrl,
      String coverUrl,
      int duration,
      int usageCount,
      bool isFavorite});
}

/// @nodoc
class _$AudioCopyWithImpl<$Res, $Val extends Audio>
    implements $AudioCopyWith<$Res> {
  _$AudioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artist = null,
    Object? audioUrl = null,
    Object? coverUrl = null,
    Object? duration = null,
    Object? usageCount = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverUrl: null == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioImplCopyWith<$Res> implements $AudioCopyWith<$Res> {
  factory _$$AudioImplCopyWith(
          _$AudioImpl value, $Res Function(_$AudioImpl) then) =
      __$$AudioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String artist,
      String audioUrl,
      String coverUrl,
      int duration,
      int usageCount,
      bool isFavorite});
}

/// @nodoc
class __$$AudioImplCopyWithImpl<$Res>
    extends _$AudioCopyWithImpl<$Res, _$AudioImpl>
    implements _$$AudioImplCopyWith<$Res> {
  __$$AudioImplCopyWithImpl(
      _$AudioImpl _value, $Res Function(_$AudioImpl) _then)
      : super(_value, _then);

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artist = null,
    Object? audioUrl = null,
    Object? coverUrl = null,
    Object? duration = null,
    Object? usageCount = null,
    Object? isFavorite = null,
  }) {
    return _then(_$AudioImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverUrl: null == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioImpl implements _Audio {
  const _$AudioImpl(
      {required this.id,
      required this.title,
      required this.artist,
      required this.audioUrl,
      required this.coverUrl,
      required this.duration,
      this.usageCount = 0,
      this.isFavorite = false});

  factory _$AudioImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String audioUrl;
  @override
  final String coverUrl;
  @override
  final int duration;
  @override
  @JsonKey()
  final int usageCount;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'Audio(id: $id, title: $title, artist: $artist, audioUrl: $audioUrl, coverUrl: $coverUrl, duration: $duration, usageCount: $usageCount, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, artist, audioUrl,
      coverUrl, duration, usageCount, isFavorite);

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioImplCopyWith<_$AudioImpl> get copyWith =>
      __$$AudioImplCopyWithImpl<_$AudioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioImplToJson(
      this,
    );
  }
}

abstract class _Audio implements Audio {
  const factory _Audio(
      {required final String id,
      required final String title,
      required final String artist,
      required final String audioUrl,
      required final String coverUrl,
      required final int duration,
      final int usageCount,
      final bool isFavorite}) = _$AudioImpl;

  factory _Audio.fromJson(Map<String, dynamic> json) = _$AudioImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get artist;
  @override
  String get audioUrl;
  @override
  String get coverUrl;
  @override
  int get duration;
  @override
  int get usageCount;
  @override
  bool get isFavorite;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioImplCopyWith<_$AudioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
