// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

import '../data/api/api_module.dart' as _i412;
import '../data/api/video_api_client.dart' as _i570;
import '../data/datasources/audio_data_source.dart' as _i76;
import '../data/datasources/local_video_data_source.dart' as _i63;
import '../data/datasources/video_remote_data_source.dart' as _i1048;
import '../data/models/audio_model/audio_model.dart' as _i557;
import '../data/models/local_video_model/local_video_model.dart' as _i11;
import '../data/repositories/audio_repository_impl.dart' as _i953;
import '../data/repositories/video_repository_impl.dart' as _i1040;
import '../domain/repositories/audio_repository.dart' as _i701;
import '../domain/repositories/video_repository.dart' as _i110;
import '../domain/usecases/delete_video_usecase.dart' as _i1062;
import '../domain/usecases/favorite_audio_usecase.dart' as _i766;
import '../domain/usecases/get_audio_by_id_usecase.dart' as _i977;
import '../domain/usecases/get_audios_usecase.dart' as _i298;
import '../domain/usecases/get_videos_usecase.dart' as _i629;
import '../domain/usecases/increment_audio_usage_usecase.dart' as _i334;
import '../domain/usecases/like_video_usecase.dart' as _i1;
import '../domain/usecases/upload_video_usecase.dart' as _i980;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  final apiModule = _$ApiModule();
  gh.singleton<_i361.Dio>(() => registerModule.dio);
  gh.singleton<_i979.Box<_i11.LocalVideoModel>>(() => registerModule.videosBox);
  gh.singleton<_i979.Box<_i557.AudioModel>>(
    () => registerModule.audiosBox,
    instanceName: 'audiosBox',
  );
  gh.singleton<_i570.VideoApiClient>(
      () => apiModule.provideVideoApiClient(gh<_i361.Dio>()));
  gh.lazySingleton<_i63.LocalVideoDataSource>(() =>
      _i63.LocalVideoDataSourceImpl(gh<_i979.Box<_i11.LocalVideoModel>>()));
  gh.lazySingleton<_i76.AudioDataSource>(() => _i76.AudioDataSourceImpl(
      gh<_i979.Box<_i557.AudioModel>>(instanceName: 'audiosBox')));
  gh.factory<_i1048.VideoRemoteDataSource>(
      () => _i1048.VideoRemoteDataSourceImpl(gh<_i570.VideoApiClient>()));
  gh.lazySingleton<_i110.VideoRepository>(() => _i1040.VideoRepositoryImpl(
        remoteDataSource: gh<_i1048.VideoRemoteDataSource>(),
        localDataSource: gh<_i63.LocalVideoDataSource>(),
      ));
  gh.lazySingleton<_i701.AudioRepository>(
      () => _i953.AudioRepositoryImpl(gh<_i76.AudioDataSource>()));
  gh.factory<_i1062.DeleteVideoUseCase>(
      () => _i1062.DeleteVideoUseCase(gh<_i110.VideoRepository>()));
  gh.factory<_i629.GetVideosUseCase>(
      () => _i629.GetVideosUseCase(gh<_i110.VideoRepository>()));
  gh.factory<_i1.LikeVideoUseCase>(
      () => _i1.LikeVideoUseCase(gh<_i110.VideoRepository>()));
  gh.factory<_i980.UploadVideoUseCase>(
      () => _i980.UploadVideoUseCase(gh<_i110.VideoRepository>()));
  gh.factory<_i766.FavoriteAudioUseCase>(
      () => _i766.FavoriteAudioUseCase(gh<_i701.AudioRepository>()));
  gh.factory<_i298.GetAudiosUseCase>(
      () => _i298.GetAudiosUseCase(gh<_i701.AudioRepository>()));
  gh.factory<_i977.GetAudioByIdUseCase>(
      () => _i977.GetAudioByIdUseCase(gh<_i701.AudioRepository>()));
  gh.factory<_i334.IncrementAudioUsageUseCase>(
      () => _i334.IncrementAudioUsageUseCase(gh<_i701.AudioRepository>()));
  return getIt;
}

class _$RegisterModule extends _i464.RegisterModule {}

class _$ApiModule extends _i412.ApiModule {}
