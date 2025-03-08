import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../data/models/audio_model/audio_model.dart';
import '../data/models/local_video_model/local_video_model.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => init(getIt);

@module
abstract class RegisterModule {
  // Network
  @singleton
  Dio get dio => Dio()
    ..options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    )
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

  // Local Storage
  @singleton
  Box<LocalVideoModel> get videosBox => Hive.box<LocalVideoModel>('videos');

  @singleton
  @Named("audiosBox")
  Box<AudioModel> get audiosBox => Hive.box<AudioModel>('audios');
}
