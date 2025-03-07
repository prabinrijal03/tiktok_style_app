import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tiktok_style_app/domain/entities/video_entity.dart';

import '../../data/data_sources/local_data_source.dart';
import '../../data/data_sources/remote_data_source.dart';
import '../../data/models/local_video/local_video_model.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/video_usecase.dart';


part 'feed_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}

@riverpod
Box<LocalVideoModel> videosBox(VideosBoxRef ref) {
  return Hive.box<LocalVideoModel>('videos');
}

@riverpod
VideoRemoteDataSource videoRemoteDataSource(VideoRemoteDataSourceRef ref) {
  return VideoRemoteDataSourceImpl(dio: ref.watch(dioProvider));
}

@riverpod
LocalVideoDataSource localVideoDataSource(LocalVideoDataSourceRef ref) {
  return LocalVideoDataSourceImpl(videosBox: ref.watch(videosBoxProvider));
}

@riverpod
VideoRepository videoRepository(VideoRepositoryRef ref) {
  return VideoRepositoryImpl(
    remoteDataSource: ref.watch(videoRemoteDataSourceProvider),
    localDataSource: ref.watch(localVideoDataSourceProvider),
  );
}

@riverpod
GetVideosUseCase getVideosUseCase(GetVideosUseCaseRef ref) {
  return GetVideosUseCase(ref.watch(videoRepositoryProvider));
}

@riverpod
UploadVideoUseCase uploadVideoUseCase(UploadVideoUseCaseRef ref) {
  return UploadVideoUseCase(ref.watch(videoRepositoryProvider));
}

@riverpod
LikeVideoUseCase likeVideoUseCase(LikeVideoUseCaseRef ref) {
  return LikeVideoUseCase(ref.watch(videoRepositoryProvider));
}

@riverpod
class VideoNotifier extends _$VideoNotifier {
  @override
  Future<List<VideoEntity>> build() async {
    return _fetchVideos();
  }

  Future<List<VideoEntity>> _fetchVideos() async {
    final getVideosUseCase = ref.read(getVideosUseCaseProvider);
    return await getVideosUseCase.execute();
  }

  Future<void> refreshVideos() async {
    try {
      final videos = await _fetchVideos();
      state = AsyncValue.data(videos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> uploadVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  }) async {
    final uploadVideoUseCase = ref.read(uploadVideoUseCaseProvider);
    
    final newVideo = await uploadVideoUseCase.execute(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      description: description,
      audioName: audioName,
    );
    
    // Update the state with the new video at the beginning of the list
    final currentVideos = state.value ?? [];
    state = AsyncValue.data([newVideo, ...currentVideos]);
  }

  Future<void> likeVideo(String videoId) async {
    final likeVideoUseCase = ref.read(likeVideoUseCaseProvider);
    
    // Optimistically update the UI
    state = AsyncValue.data(
      state.value?.map((video) {
        if (video.id == videoId) {
          return VideoEntity(
            id: video.id,
            videoUrl: video.videoUrl,
            thumbnailUrl: video.thumbnailUrl,
            description: video.description,
            username: video.username,
            audioName: video.audioName,
            likes: video.isLiked ? video.likes - 1 : video.likes + 1,
            comments: video.comments,
            shares: video.shares,
            isLiked: !video.isLiked,
            isLocalFile: video.isLocalFile,
          );
        }
        return video;
      }).toList() ?? [],
    );
    
    // Call the API
    await likeVideoUseCase.execute(videoId);
  }
  
  Future<void> deleteVideo(String videoId) async {
    final repository = ref.read(videoRepositoryProvider);
    await repository.deleteVideo(videoId);
    
    // Update the state by removing the deleted video
    final currentVideos = state.value ?? [];
    state = AsyncValue.data(
      currentVideos.where((video) => video.id != videoId).toList(),
    );
  }
}

@riverpod
class CurrentVideoIndex extends _$CurrentVideoIndex {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}

