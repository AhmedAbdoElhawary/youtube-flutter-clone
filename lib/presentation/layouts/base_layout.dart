import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube/config/themes/theme_service.dart';
import 'package:youtube/core/resources/assets_manager.dart';
import 'package:youtube/core/resources/color_manager.dart';
import 'package:youtube/core/utility/constants.dart';
import 'package:youtube/presentation/common_widgets/svg_icon.dart';
import 'package:youtube/presentation/custom_packages/custom_tab_scaffold/custom_bottom_tab_bar.dart';
import 'package:youtube/presentation/custom_packages/custom_tab_scaffold/custom_tab_scaffold.dart';
import 'package:youtube/presentation/layouts/base_layout_logic.dart';
import 'package:youtube/presentation/pages/home/logic/home_page_logic.dart';
import 'package:youtube/presentation/pages/home/views/home_page.dart';
import 'package:youtube/presentation/pages/library/library_page.dart';
import 'package:youtube/presentation/pages/shorts/shorts_page.dart';

import '../pages/subscriptions/subscriptions_page.dart';
import '../common_widgets/mini_player_video/mini_player_video.dart';

class BaseLayout extends StatefulWidget {
  const BaseLayout({super.key});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    final baseLayoutLogic = Get.find<BaseLayoutLogic>(tag: "1");
    final miniVideoLogic = Get.put(MiniVideoViewLogic(), tag: "1");

    return Obx(
      () {
        bool isThemeDark = ThemeOfApp().isThemeDark();

        bool isShortsPageSelected =
            baseLayoutLogic.isShortsPageSelected && !isThemeDark;

        Color? color = isShortsPageSelected ? BaseColorManager.white : null;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              statusBarColor: ColorManager(context).white,
              statusBarIconBrightness:
                  isThemeDark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: ColorManager(context).white,
              systemNavigationBarColor: ColorManager(context).white,
              statusBarBrightness:
                  isThemeDark ? Brightness.dark : Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light),
          child: CustomCupertinoTabScaffold(
            tabBar: CustomCupertinoTabBar(
              backgroundColor: isShortsPageSelected && !isThemeDark
                  ? Theme.of(context).focusColor
                  : Theme.of(context).primaryColor,
              height: miniVideoLogic.heightOfNavigationBar.value.h,
              border: Border(
                  top: BorderSide(
                      color: isShortsPageSelected
                          ? ColorManager(context).grey9
                          : ColorManager(context).grey1,
                      width: 1.w)),
              inactiveColor: isShortsPageSelected
                  ? ColorManager(context).white
                  : ColorManager(context).black,
              activeColor: isShortsPageSelected
                  ? ColorManager(context).white
                  : ColorManager(context).black,
              items: [
                BottomNavigationBarItem(
                    icon: SvgIcon(IconsAssets.homeIcon, size: 25, color: color),
                    activeIcon:
                        const SvgIcon(IconsAssets.homeColoredIcon, size: 25),
                    label: "Home"),
                BottomNavigationBarItem(
                    icon:
                        SvgIcon(IconsAssets.shortsIcon, size: 25, color: color),
                    activeIcon:
                        SvgIcon(IconsAssets.shortsIcon, size: 25, color: color),
                    label: "Shorts"),
                BottomNavigationBarItem(
                  icon: SvgIcon(IconsAssets.addIcon, size: 35, color: color),
                  activeIcon: const SvgIcon(IconsAssets.addIcon, size: 35),
                ),
                BottomNavigationBarItem(
                    icon: SvgIcon(IconsAssets.subscriptionIcon,
                        size: 25, color: color),
                    activeIcon: const SvgIcon(
                        IconsAssets.subscriptionColoredIcon,
                        size: 25),
                    label: "Subscriptions"),
                BottomNavigationBarItem(
                    icon: SvgIcon(IconsAssets.libraryIcon,
                        size: 25, color: color),
                    activeIcon:
                        const SvgIcon(IconsAssets.libraryColoredIcon, size: 25),
                    label: "Library"),
              ],
            ),
            // controller: baseLayoutLogic.tabController,
            tabBuilder: (context, index) {
              if (index == 1) return const _ShortsPage();

              return _FloatingVideo(index: index);
            },
          ),
        );
      },
    );
  }

  BottomNavigationBarItem navigationBarItem(
      String icon, String activeIcon, String label) {
    bool isThatAdd = label == "Account";
    return BottomNavigationBarItem(
        icon: SvgIcon(icon, size: isThatAdd ? 40.r : 25.r),
        activeIcon: SvgIcon(activeIcon, size: isThatAdd ? 40.r : 25.r),
        label: isThatAdd ? null : label);
  }
}

class WhichPage extends StatelessWidget {
  const WhichPage(this.index, {Key? key}) : super(key: key);
  final int index;
  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const _HomePage();
      case 1:
        return const _ShortsPage();
      case 3:
        return const _SubscriptionsPage();
      default:
        return const _LibraryPage();
    }
  }
}

class _FloatingVideo extends StatefulWidget {
  final int index;
  const _FloatingVideo({required this.index});

  @override
  State<_FloatingVideo> createState() => _FloatingVideoState();
}

class _FloatingVideoState extends State<_FloatingVideo> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MiniVideoViewLogic>(
      tag: "1",
      id: "update-base-selected-video",
      builder: (controller) {
        Widget floatingVideo = !controller.showFloatingVideo ||
                controller.getSelectedVideoDetails == null
            ? const SizedBox()
            : const MiniPlayerVideo();

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            WhichPage(widget.index),
            floatingVideo,
          ],
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) => const CupertinoPageScaffold(child: HomePage()),
    );
  }
}

class _ShortsPage extends StatelessWidget {
  const _ShortsPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) => const CupertinoPageScaffold(child: ShortsPage()),
    );
  }
}

class _SubscriptionsPage extends StatelessWidget {
  const _SubscriptionsPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) =>
          const CupertinoPageScaffold(child: SubscriptionsPage()),
    );
  }
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) => const CupertinoPageScaffold(child: LibraryPage()),
    );
  }
}
