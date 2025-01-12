// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

class RecommendPosts<T extends Post> extends StatelessWidget {
  const RecommendPosts({
    super.key,
    required this.title,
    required this.items,
    required this.onHeaderTap,
    required this.onTap,
    required this.imageUrl,
  });

  final List<T> items;
  final void Function() onHeaderTap;
  final void Function(int postIndex) onTap;
  final String Function(T item) imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: RecommendPostSection(
        header: ListTile(
          onTap: () => onHeaderTap(),
          title: Text(title),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
        ),
        posts: items,
        onTap: (postIdx) => onTap(postIdx),
        imageUrl: imageUrl,
      ),
    );
  }
}
