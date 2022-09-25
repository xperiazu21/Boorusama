// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';

class PreviewPostGrid extends StatelessWidget {
  const PreviewPostGrid({
    Key? key,
    required this.posts,
    required this.imageQuality,
    this.physics,
  }) : super(key: key);

  final List<PostData> posts;
  final ScrollPhysics? physics;
  final ImageQuality imageQuality;

  @override
  Widget build(BuildContext context) {
    void handleTap(int index) {
      AppRouter.router.navigateTo(
        context,
        '/post/detail',
        routeSettings: RouteSettings(
          arguments: [
            posts,
            index,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          shrinkWrap: true,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: GestureDetector(
              onTap: () => handleTap(index),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: _getImageUrl(
                  posts[index].post,
                  imageQuality,
                ),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _getImageUrl(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.previewImageUrl;
  if (quality == ImageQuality.high) return post.normalImageUrl;
  return post.previewImageUrl;
}