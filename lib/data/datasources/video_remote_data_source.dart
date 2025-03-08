import 'package:injectable/injectable.dart';


import '../api/video_api_client.dart';
import '../models/video_model/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos();
  Future<void> likeVideo(String videoId);
}

@Injectable(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final VideoApiClient apiClient;

  VideoRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final response = await apiClient.getVideos(10);
      
      return response.map((item) => VideoModel(
        id: item.id.toString(),
        videoUrl: _getReliableVideoUrl(item.id),
        thumbnailUrl: item.thumbnailUrl,
        description: item.title,
        username: 'user_${item.albumId}',
        audioName: 'Original Sound',
        likes: (item.id * 100) % 1000,
        comments: (item.id * 50) % 500,
        shares: (item.id * 25) % 250,
      )).toList();
    } catch (e) {
      return _getMockVideos();
    }
  }

  @override
  Future<void> likeVideo(String videoId) async {
    try {
      await apiClient.likeVideo(videoId);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  String _getReliableVideoUrl(int id) {
    final reliableVideoUrls = [
      'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    ];
    
    return reliableVideoUrls[id % reliableVideoUrls.length];
  }

  // Mock data for testing
  List<VideoModel> _getMockVideos() {
    return List.generate(
      10,
      (index) => VideoModel(
        id: index.toString(),
        videoUrl: _getReliableVideoUrl(index),
        thumbnailUrl: 'https://via.placeholder.com/150/${(index * 100) % 999}',
        description: 'This is a mock video description #${index + 1}',
        username: 'user_${index + 1}',
        audioName: 'Original Sound',
        likes: (index * 100) % 1000,
        comments: (index * 50) % 500,
        shares: (index * 25) % 250,
      ),
    );
  }
}

