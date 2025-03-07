// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'58eeefbd0832498ca2574c1fe69ed783c58d1d8f';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$videosBoxHash() => r'c94cdcf81a244442139fd583944f1deb646fc0ce';

/// See also [videosBox].
@ProviderFor(videosBox)
final videosBoxProvider = AutoDisposeProvider<Box<LocalVideoModel>>.internal(
  videosBox,
  name: r'videosBoxProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videosBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideosBoxRef = AutoDisposeProviderRef<Box<LocalVideoModel>>;
String _$videoRemoteDataSourceHash() =>
    r'864c0107edfd06d5df5f6025c07ec8074004c8bf';

/// See also [videoRemoteDataSource].
@ProviderFor(videoRemoteDataSource)
final videoRemoteDataSourceProvider =
    AutoDisposeProvider<VideoRemoteDataSource>.internal(
  videoRemoteDataSource,
  name: r'videoRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoRemoteDataSourceRef
    = AutoDisposeProviderRef<VideoRemoteDataSource>;
String _$localVideoDataSourceHash() =>
    r'8586d20e8d7ef4218843947eb4c7ee8dbcc7bd5a';

/// See also [localVideoDataSource].
@ProviderFor(localVideoDataSource)
final localVideoDataSourceProvider =
    AutoDisposeProvider<LocalVideoDataSource>.internal(
  localVideoDataSource,
  name: r'localVideoDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localVideoDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalVideoDataSourceRef = AutoDisposeProviderRef<LocalVideoDataSource>;
String _$videoRepositoryHash() => r'732233513cebd28640fe46edea338644b23537e2';

/// See also [videoRepository].
@ProviderFor(videoRepository)
final videoRepositoryProvider = AutoDisposeProvider<VideoRepository>.internal(
  videoRepository,
  name: r'videoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoRepositoryRef = AutoDisposeProviderRef<VideoRepository>;
String _$getVideosUseCaseHash() => r'3cd21fb450513dda2378383f1528a3c652e65d2d';

/// See also [getVideosUseCase].
@ProviderFor(getVideosUseCase)
final getVideosUseCaseProvider = AutoDisposeProvider<GetVideosUseCase>.internal(
  getVideosUseCase,
  name: r'getVideosUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getVideosUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetVideosUseCaseRef = AutoDisposeProviderRef<GetVideosUseCase>;
String _$uploadVideoUseCaseHash() =>
    r'9937e86aa2741b6d186fc3f5a35679fbb6f82df6';

/// See also [uploadVideoUseCase].
@ProviderFor(uploadVideoUseCase)
final uploadVideoUseCaseProvider =
    AutoDisposeProvider<UploadVideoUseCase>.internal(
  uploadVideoUseCase,
  name: r'uploadVideoUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadVideoUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadVideoUseCaseRef = AutoDisposeProviderRef<UploadVideoUseCase>;
String _$likeVideoUseCaseHash() => r'18d89b566f32d09663dba4783e1ba3573364687c';

/// See also [likeVideoUseCase].
@ProviderFor(likeVideoUseCase)
final likeVideoUseCaseProvider = AutoDisposeProvider<LikeVideoUseCase>.internal(
  likeVideoUseCase,
  name: r'likeVideoUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$likeVideoUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LikeVideoUseCaseRef = AutoDisposeProviderRef<LikeVideoUseCase>;
String _$videoNotifierHash() => r'bb474f83cfb27a649146a70cb48e9cba4fc77fc4';

/// See also [VideoNotifier].
@ProviderFor(VideoNotifier)
final videoNotifierProvider =
    AutoDisposeAsyncNotifierProvider<VideoNotifier, List<VideoEntity>>.internal(
  VideoNotifier.new,
  name: r'videoNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoNotifier = AutoDisposeAsyncNotifier<List<VideoEntity>>;
String _$currentVideoIndexHash() => r'82637a7028c5f9839de6c104c00f5c53b6469ffe';

/// See also [CurrentVideoIndex].
@ProviderFor(CurrentVideoIndex)
final currentVideoIndexProvider =
    AutoDisposeNotifierProvider<CurrentVideoIndex, int>.internal(
  CurrentVideoIndex.new,
  name: r'currentVideoIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentVideoIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentVideoIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
