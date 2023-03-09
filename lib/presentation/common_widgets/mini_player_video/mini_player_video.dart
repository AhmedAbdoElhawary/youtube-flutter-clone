import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:youtube/config/routes/route_app.dart';
import 'package:youtube/core/functions/handling_errors/network_exceptions.dart';
import 'package:youtube/core/functions/toast_show.dart';
import 'package:youtube/core/resources/assets_manager.dart';
import 'package:youtube/core/resources/color_manager.dart';
import 'package:youtube/core/resources/styles_manager.dart';
import 'package:youtube/data/models/comment_details/comment_details.dart';
import 'package:youtube/data/models/comment_details/comment_details_extension.dart';
import 'package:youtube/data/models/common/base_comment_snippet/sub_comment_snippet.dart';
import 'package:youtube/data/models/rating_details/rating_details.dart';
import 'package:youtube/data/models/videos_details/video_details_extension.dart';
import 'package:youtube/data/models/videos_details/videos_details.dart';
import 'package:youtube/presentation/common_widgets/circular_profile_image.dart';
import 'package:youtube/presentation/common_widgets/container_loading.dart';
import 'package:youtube/presentation/common_widgets/custom_circle_progress.dart';
import 'package:youtube/presentation/common_widgets/error_message_widget.dart';
import 'package:youtube/presentation/common_widgets/read_more_text.dart';
import 'package:youtube/presentation/common_widgets/subscribe_button.dart';
import 'package:youtube/presentation/common_widgets/svg_icon.dart';
import 'package:youtube/presentation/common_widgets/text_links.dart';
import 'package:youtube/presentation/common_widgets/thumbnail_of_video.dart';
import 'package:youtube/presentation/common_widgets/videos_list_loading.dart';
import 'package:youtube/presentation/cubit/search/search_cubit.dart';
import 'package:youtube/presentation/cubit/single_video/single_video_cubit.dart';
import 'package:youtube/presentation/custom_packages/custom_mini_player/custom_mini_player.dart';
import 'package:youtube/presentation/custom_packages/pod_player/src/pod_player.dart';
import 'package:youtube/presentation/layouts/base_layout_logic.dart';
import 'package:youtube/presentation/pages/channel_profile/user_channel_page.dart';
import 'package:youtube/presentation/pages/home/logic/home_page_logic.dart';

import '../../custom_packages/sliding_sheet/sliding_sheet.dart';
import 'sub_widgets/interaction_simmer_loading.dart';

part 'sub_widgets/like_button.dart';
part 'sub_widgets/loading_widgets.dart';
part 'sub_widgets/dislike_button.dart';
part 'sub_widgets/mini_video_view.dart';
part 'sub_widgets/bottom_sheet/draggable_bottom_sheet.dart';
part 'sub_widgets/fisrt_comment_preview_button.dart';
part 'sub_widgets/bottom_sheet/description_bottom_sheet.dart';
part 'sub_widgets/bottom_sheet/head_of_bottom_sheet.dart';
part 'sub_widgets/bottom_sheet/comments_bottom_sheet.dart';

class MiniPlayerVideo extends StatefulWidget {
  const MiniPlayerVideo({super.key});

  @override
  State<MiniPlayerVideo> createState() => _MiniPlayerVideoState();
}

class _MiniPlayerVideoState extends State<MiniPlayerVideo> {
  final _miniVideoViewLogic = Get.find<MiniVideoViewLogic>(tag: "1");
  final baseLayoutLogic = Get.find<BaseLayoutLogic>(tag: "1");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomMiniPlayer(
        controller: _miniVideoViewLogic.miniPlayerController,
        minHeight: _miniVideoViewLogic.minHeight,
        maxHeight: _miniVideoViewLogic.maxHeight,
        onDismissed: () {
          _miniVideoViewLogic.selectedVideoDetails = null;
          _miniVideoViewLogic.isMiniVideoInitialized.value = false;
          try {
            _miniVideoViewLogic.videoController?.dispose();
          } catch (e) {
            rethrow;
          }
        },
        builder: (height, percentage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _miniVideoViewLogic.percentageOFMiniPage = percentage;
            _miniVideoViewLogic.heightOFMiniPage = height;
          });

          return _MiniVideoDisplay(height, percentage);
        },
      ),
    );
  }
}

class _MiniVideoDisplay extends StatelessWidget {
  const _MiniVideoDisplay(this.height, this.percentage);
  final double height;
  final double percentage;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: GetBuilder<MiniVideoViewLogic>(
          tag: "1",
          id: "update mini player",
          builder: (miniVideoViewLogic) => Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: miniVideoViewLogic.videoOfMiniDisplayHeight(
                        screenHeight: height, percentage: percentage)),
                child: const _NextVideosSuggestions(),
              ),
              _MiniVideoView(
                  height: height,
                  percentage: percentage,
                  durationVideoValue:
                      miniVideoViewLogic.getDurationVideoValue(),
                  isPlaying: miniVideoViewLogic.isMiniVideoPlaying),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextVideosSuggestions extends StatelessWidget {
  const _NextVideosSuggestions();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logic = Get.find<MiniVideoViewLogic>(tag: "1");
      String videoId = logic.selectedVideoDetails?.id ?? "";
      return BlocBuilder<SearchCubit, SearchState>(
        bloc: SearchCubit.get(context)..relatedVideosToThisVideo(videoId),
        buildWhen: (previous, current) =>
            previous != current &&
            (current is RelatedVideosLoaded || current is SearchLoading),
        builder: (context, state) {
          if (state is RelatedVideosLoaded) {
            return CustomScrollView(
              slivers: [
                const _VideoInfo(),
                _RelatedVideosList(state),
              ],
            );
          } else if (state is SearchError) {
            return ErrorMessageWidget(state.networkExceptions);
          } else {
            return const _LoadingWidgets();
          }
        },
      );
    });
  }
}

class _RelatedVideosList extends StatelessWidget {
  const _RelatedVideosList(this.state);
  final RelatedVideosLoaded state;
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ThumbnailOfVideo(state.videosDetails.videoDetailsItem![index],
              enablePlaying: false);
        },
        childCount: state.videosDetails.videoDetailsItem?.length ?? 0,
      ),
    );
  }
}

class _VideoInfo extends StatelessWidget {
  const _VideoInfo();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: REdgeInsets.only(top: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _VideoTitleSubNumbersTexts(),
            const _InteractButtons(),
            Divider(color: ColorManager(context).grey1Point5),
            const _CircleNameSubscribersWidget(),
            Divider(color: ColorManager(context).grey1Point5),
            const _FirstCommentPreviewButton(),
            const RSizedBox(height: 15),
            Divider(
                color: ColorManager(context).grey1, height: 1, thickness: 7),
          ],
        ),
      ),
    );
  }
}

class _CircleNameSubscribersWidget extends StatelessWidget {
  const _CircleNameSubscribersWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Obx(
        () {
          final logic = Get.find<MiniVideoViewLogic>(tag: "1");
          VideoDetailsItem? videoDetails = logic.selectedVideoDetails;

          return InkWell(
            onTap: () {
              Go(context).to(UserChannelPage(
                UserChannelPageParameters(
                  channelDetailsItem: videoDetails?.getChannelSubDetails(),
                  channelId: videoDetails?.getChannelId() ?? "",
                ),
              ));
            },
            child: Row(
              children: [
                CircularProfileImage(
                  imageUrl: videoDetails?.getChannelProfileImageUrl() ?? "",
                  radius: 17.r,
                ),
                const RSizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoDetails?.getChannelName() ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: getMediumStyle(
                            color: ColorManager(context).black, fontSize: 15),
                      ),
                      const RSizedBox(height: 5),
                      Text(
                        "${videoDetails?.getSubscribersCount() ?? " "} subscribers",
                        overflow: TextOverflow.ellipsis,
                        style: getNormalStyle(
                            color: ColorManager(context).grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                SubscribeButton(
                    channelId: videoDetails?.getChannelId() ?? "",
                    makeItExpanded: false,
                    fontSize: 13),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InteractButtons extends StatelessWidget {
  const _InteractButtons();

  @override
  Widget build(BuildContext context) {
    return RSizedBox(
      height: 60.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const _LikeButton(),
            Padding(
              padding: REdgeInsetsDirectional.only(start: 35, top: 15),
              child: const _DislikeButton(),
            ),
            Padding(
              padding: REdgeInsetsDirectional.only(start: 35, top: 15),
              child: const _IconText(size: 23),
            ),
            Padding(
              padding: REdgeInsetsDirectional.only(start: 35, top: 15),
              child: const _IconText(
                  text: "Download", iconAsset: IconsAssets.downloadIcon,size: 20),
            ),
            Padding(
              padding: REdgeInsetsDirectional.only(start: 35,end: 35, top: 15),
              child: const _IconText(
                  text: "Save", iconAsset: IconsAssets.libraryIcon),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText(
      {this.size=25,this.iconAsset = IconsAssets.shareIcon, this.text = "Share", Key? key})
      : super(key: key);
  final String text;
  final String iconAsset;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgIcon(iconAsset,size: size),
        const RSizedBox(height: 5),
        Text(
          text,
          style:
              getNormalStyle(color: ColorManager(context).black, fontSize: 13),
        )
      ],
    );
  }
}

class _VideoTitleSubNumbersTexts extends StatelessWidget {
  const _VideoTitleSubNumbersTexts();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        draggableBottomSheet(context);
      },
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () {
                final logic = Get.find<MiniVideoViewLogic>(tag: "1");
                VideoDetailsItem? videoDetails = logic.selectedVideoDetails;
                return Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoDetails?.getVideoTitle() ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: getNormalStyle(
                            color: ColorManager(context).black, fontSize: 15),
                      ),
                      const RSizedBox(height: 8),
                      Text(
                        "${videoDetails?.getVideoViewsCount()} views . ${videoDetails?.getVideoPublishedTime()} ago",
                        overflow: TextOverflow.ellipsis,
                        style: getNormalStyle(
                            color: ColorManager(context).grey7, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Icon(Icons.keyboard_arrow_down_outlined),
          ],
        ),
      ),
    );
  }
}
