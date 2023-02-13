import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube/config/routes/route_app.dart';

import '../../core/resources/color_manager.dart';
import '../pages/channel_profile/user_profile_page.dart';

class CircularProfileImage extends StatelessWidget {
  final bool enableTapping;
  final double radius;
  final String imageUrl;
  const CircularProfileImage(
      {this.imageUrl = "",
      this.enableTapping = true,
      this.radius = 18,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !enableTapping
          ? null
          : () {
              Go(context).to(const UserProfilePage());
            },
      child: CircleAvatar(
        radius: radius.r,
        backgroundColor: ColorManager(context).grey,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      ),
    );
  }
}
