// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../di/injection.dart';
import '../../../domain/entities/video/video.dart';
import '../../../domain/usecases/delete_video_usecase.dart';
import '../../../domain/usecases/get_videos_usecase.dart';
import '../../../domain/usecases/like_video_usecase.dart';
import '../../../domain/usecases/upload_video_usecase.dart';

part 'video_providers.g.dart';

@riverpod
GetVideosUseCase getVideosUseCase(GetVideosUseCaseRef ref) {
  return getIt<GetVideosUseCase>();
}

@riverpod
UploadVideoUseCase uploadVideoUseCase(UploadVideoUseCaseRef ref) {
  return getIt<UploadVideoUseCase>();
}

@riverpod
LikeVideoUseCase likeVideoUseCase(LikeVideoUseCaseRef ref) {
  return getIt<LikeVideoUseCase>();
}

@riverpod
DeleteVideoUseCase deleteVideoUseCase(DeleteVideoUseCaseRef ref) {
  return getIt<DeleteVideoUseCase>();
}

@riverpod
class VideoNotifier extends _$VideoNotifier {
  @override
  Future<List<Video>> build() async {
    return _fetchVideos();
  }

  Future<List<Video>> _fetchVideos() async {
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
    String? audioId,
  }) async {
    final uploadVideoUseCase = ref.read(uploadVideoUseCaseProvider);

    final newVideo = await uploadVideoUseCase.execute(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      description: description,
      audioName: audioName,
      audioId: audioId,
    );

    
    final currentVideos = state.value ?? [];
    state = AsyncValue.data([newVideo, ...currentVideos]);
  }

  Future<void> likeVideo(String videoId) async {
    final likeVideoUseCase = ref.read(likeVideoUseCaseProvider);

    
    state = AsyncValue.data(
      state.value?.map((video) {
            if (video.id == videoId) {
              return video.copyWith(
                likes: video.isLiked ? video.likes - 1 : video.likes + 1,
                isLiked: !video.isLiked,
              );
            }
            return video;
          }).toList() ??
          [],
    );

    
    await likeVideoUseCase.execute(videoId);
  }

  Future<void> deleteVideo(String videoId) async {
    final deleteVideoUseCase = ref.read(deleteVideoUseCaseProvider);
    await deleteVideoUseCase.execute(videoId);

    
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
