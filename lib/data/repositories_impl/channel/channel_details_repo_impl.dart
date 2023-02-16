import 'package:youtube/core/functions/api_result.dart';

import 'package:youtube/core/utility/private_key.dart';
import 'package:youtube/data/data_sources/remote/api/channel/channel_apis.dart';
import 'package:youtube/data/models/channel_details/channel_details.dart';
import 'package:youtube/data/models/channel_details/my_subscriptions_details.dart';
import 'package:youtube/data/models/channel_details/subscribe_request_body.dart';
import 'package:youtube/data/models/videos_details/videos_details.dart';
import 'package:youtube/domain/repositories/channel/channel_details_repository.dart';

class ChannelDetailsRepoImpl implements ChannelDetailsRepository {
  final ChannelAPIs _channelAPIs;
  ChannelDetailsRepoImpl(this._channelAPIs);

  @override
  Future<ApiResult<ChannelSubDetails>> getSubSingleChannelDetails(
      {required String channelId}) async {
    try {
      ChannelSubDetails channelSubDetails =
          await _channelAPIs.getSubChannelInfo(channelId: channelId);
      return ApiResult.success(channelSubDetails);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<void>> subscribeToChannel(
      {required String channelId}) async {
    try {
      await _channelAPIs.subscribeToChannel(
          accessToken: accessToken,
          body: SubscriptionRequestBody.toJson(channelId));
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<void>> deleteSubscription() async {
    try {
      await _channelAPIs.deleteSubscription(
          accessToken: accessToken, id: idToken);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<VideosDetails> getSubChannelsDetails(
      {required VideosDetails videosDetails}) async {
    try {
      for (final item
          in videosDetails.videoDetailsItem ?? <VideoDetailsItem>[]) {
        String channelId = item.snippet?.channelId ?? "";
        ChannelSubDetails subChannelDetails =
            await _channelAPIs.getSubChannelInfo(channelId: channelId);
        item.snippet?.channelSubDetails = subChannelDetails;
      }
      return videosDetails;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<ApiResult<MySubscriptionsDetails>> getMySubscriptionsChannels() async {
    try {
      MySubscriptionsDetails mySubscriptions = await _channelAPIs
          .getMySubscriptionsChannels(accessToken: accessToken);
      return ApiResult.success(mySubscriptions);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
