import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tiktok_style_app/data/api/video_api_client.dart';

@module
abstract class ApiModule {
  @singleton
  VideoApiClient provideVideoApiClient(Dio dio) => VideoApiClient(dio);
}

