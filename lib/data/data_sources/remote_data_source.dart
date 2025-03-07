import 'package:dio/dio.dart';

import '../models/video_model/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos();
  Future<void> likeVideo(String videoId);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  VideoRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = 'https://jsonplaceholder.typicode.com', // Mock API
  });

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      // For mock data, we'll use the photos endpoint from JSONPlaceholder
      final response = await dio.get('$baseUrl/photos?_limit=10');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        // Transform the mock data into our video model
        return data.map((item) => VideoModel(
          id: item['id'].toString(),
          // Use reliable video URLs that don't have CORS restrictions
          videoUrl: _getReliableVideoUrl(int.parse(item['id'].toString())),
          thumbnailUrl: item['thumbnailUrl'] ?? item['url'],
          description: item['title'] ?? 'No description',
          username: 'user_${item['albumId']}',
          audioName: 'Original Sound',
          likes: (item['id'] * 100) % 1000, // Mock likes count
          comments: (item['id'] * 50) % 500, // Mock comments count
          shares: (item['id'] * 25) % 250, // Mock shares count
        )).toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      // For demo purposes, return mock data if the API call fails
      return _getMockVideos();
    }
  }

  @override
  Future<void> likeVideo(String videoId) async {
    try {
      // In a real app, you would send a request to like the video
      // For this mock implementation, we'll just pretend we did
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to like video: $e');
    }
  }

  // Get a reliable video URL that doesn't have CORS restrictions
  String _getReliableVideoUrl(int id) {
    // These are public domain videos from Google's sample video bucket
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

