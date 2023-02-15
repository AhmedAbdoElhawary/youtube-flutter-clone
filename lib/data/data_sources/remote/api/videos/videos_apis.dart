import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:youtube/core/utility/constants.dart';
import 'package:youtube/core/utility/private_key.dart';
import 'package:youtube/data/models/common/videos_ids/videos_ids.dart';
import 'package:youtube/data/models/videos_details/videos_details.dart';
part 'videos_apis.g.dart';

@RestApi(baseUrl: youtubeBaseUrl)
abstract class VideosAPIs {
  factory VideosAPIs(Dio dio, {String baseUrl}) = _VideosAPIs;

  @GET("search?part=id&maxResults=50&regionCode=EG")
  Future<VideosIdsDetails> getAllVideosIds({
    @Query("key") final String apiKey = apiKey,
  });

  @GET("search?part=id&maxResults=50&regionCode=EG&videoDuration=short")
  Future<VideosIdsDetails> getAllShortVideosIds({
    @Query("key") final String apiKey = apiKey,
  });

  /// [videosIds] add ids like this: id1,id2,id3,id4
  @GET("search?part=id&maxResults=50&regionCode=EG")
  Future<VideosDetails> getVideosOfThoseIds({
    @Query("key") final String apiKey = apiKey,
    @Query("key") required String videosIds,
  });

  @GET(
      "videos?part=contentDetails,statistics,snippet&chart=mostPopular&maxResults=50&regionCode=EG")
  Future<VideosDetails> getMostPopularVideos({
    @Query("key") final String apiKey = apiKey,
  });
}
