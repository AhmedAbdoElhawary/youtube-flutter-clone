import 'package:youtube/core/functions/api_result.dart';

import 'package:youtube/data/data_sources/remote/api/videos/videos_apis.dart';
import 'package:youtube/data/models/common/videos_ids/videos_ids.dart';
import 'package:youtube/data/models/videos_details/videos_details.dart';
import 'package:youtube/domain/repositories/channel/channel_details_repository.dart';
import 'package:youtube/domain/repositories/videos_details_repository.dart';

class VideosDetailsRepoImpl implements VideosDetailsRepository {
  final VideosAPIs _videosAPIs;
  final ChannelDetailsRepository _channelDetailsRepository;
  VideosDetailsRepoImpl(this._videosAPIs, this._channelDetailsRepository);

  @override
  Future<ApiResult<VideosDetails>> getAllVideos() async {
    try {
      VideosIdsDetails videos = await _videosAPIs.getAllVideosIds();

      VideosDetails videosWithSubChannelDetails =
          await getCompleteVideosDetailsOfThoseIds(videos);

      return ApiResult.success(videosWithSubChannelDetails);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<VideosDetails>> getAllShortVideos() async {
    try {
      VideosIdsDetails videos = await _videosAPIs.getAllShortVideosIds();

      VideosDetails videosWithSubChannelDetails =
          await getCompleteVideosDetailsOfThoseIds(videos);

      return ApiResult.success(videosWithSubChannelDetails);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<VideosDetails>> getMostPopularVideos(
      String videoCategoryId) async {
    try {
      VideosDetails videos = await _videosAPIs.getMostPopularVideos(
          videoCategoryId: videoCategoryId);

      VideosDetails videosWithSubChannelDetails =
          await _channelDetailsRepository.getSubChannelsDetails(
              videosDetails: videos);

      return ApiResult.success(videosWithSubChannelDetails);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<VideosDetails> getCompleteVideosDetailsOfThoseIds(
      VideosIdsDetails videosIdsDetails) async {
    try {
      String ids = "";
      for (final videoIdItem in videosIdsDetails.items ?? <VideoIdItem>[]) {
        String id = videoIdItem?.id?.videoId ?? "";
        if (id.isEmpty) continue;
        if (ids.isEmpty) {
          ids = id;
          continue;
        }
        ids += ",$id";
      }

      VideosDetails videos =
          await _videosAPIs.getVideosOfThoseIds(videosIds: ids);

      VideosDetails videosWithSubChannelDetails =
          await _channelDetailsRepository.getSubChannelsDetails(
              videosDetails: videos);

      return videosWithSubChannelDetails;
    } catch (e) {
      return Future.error(e);
    }
  }
}
