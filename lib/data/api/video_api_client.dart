import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../models/video_response/video_response.dart';


part 'video_api_client.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com")
abstract class VideoApiClient {
  @factoryMethod
  factory VideoApiClient(Dio dio) = _VideoApiClient;

  @GET("/photos")
  Future<List<VideoResponse>> getVideos(@Query("_limit") int limit);
  
  @GET("/photos/{id}")
  Future<VideoResponse> getVideo(@Path("id") String id);
  
  @POST("/photos/{id}/like")
  Future<void> likeVideo(@Path("id") String id);
}

