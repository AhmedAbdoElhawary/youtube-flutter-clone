part of '../shorts_page.dart';

class _ShortPlayer extends StatefulWidget {
  const _ShortPlayer(this.videoDetailsItem, {Key? key}) : super(key: key);
  final VideoDetailsItem videoDetailsItem;
  @override
  State<_ShortPlayer> createState() => _ShortPlayerState();
}

class _ShortPlayerState extends State<_ShortPlayer> {
  final logic = Get.find<ShortsLogic>(tag: "1");
  final baseLayoutLogic = Get.find<BaseLayoutLogic>(tag: "1");
  String videoId = "";
  @override
  void initState() {
    super.initState();
    videoId = widget.videoDetailsItem.id ?? "";
    logic.videoController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube('https://youtu.be/$videoId'),
    )..initialise();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShortsLogic>(
      id: "update current short",
      tag: "1",
      builder: (logic) {
        return Stack(
            children: [
        GestureDetector(
          onTap: onTapVideo,
          child: CustomPodVideoPlayer(
              controller: logic.videoController,
              frameAspectRatio: 9 / 17.7),
        ),
        Center(child: logic.videoStatusAnimation),
            ],
          );
      },
    );
  }

  void onTapVideo() {
    if (!logic.videoController.isInitialised) return;

    if (!logic.videoController.isVideoPlaying) {
      logic.videoStatusAnimation = const _FadeAnimation(
          child: _VolumeContainer(Icons.play_arrow_rounded));
      logic.videoController.play();
    } else {
      logic.videoStatusAnimation =
          const _FadeAnimation(child: _VolumeContainer(Icons.pause));
      logic.videoController.pause();
    }
  }
}

class _VolumeContainer extends StatelessWidget {
  const _VolumeContainer(this.icon, {Key? key}) : super(key: key);
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: ColorManager(context).black87),
      padding: const EdgeInsetsDirectional.all(25),
      child: Icon(
        icon,
        size: 23.0,
        color: ColorManager(context).white,
      ),
    );
  }
}

class _FadeAnimation extends StatefulWidget {
  const _FadeAnimation({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<_FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();

    super.deactivate();
  }

  @override
  void didUpdateWidget(_FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => animationController.isAnimating
      ? AnimatedBuilder(
          animation: animationController,
          builder: (context, child) => AnimatedOpacity(
            opacity: 1.0 - animationController.value,
            duration: const Duration(milliseconds: 10),
            child: widget.child,
          ),
        )
      : const SizedBox();
}
