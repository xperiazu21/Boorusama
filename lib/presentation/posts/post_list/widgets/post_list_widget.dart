import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_bottom_loader_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/post_list_swipe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PostList extends StatefulWidget {
  PostList(
      {Key key,
      @required this.posts,
      @required this.onMaxItemReached,
      @required this.scrollThreshold,
      @required this.scrollController})
      : super(key: key);

  final List<Post> posts;
  final ValueChanged onMaxItemReached;
  final scrollThreshold;
  final scrollController;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: _buildGrid,
    );
  }

  Widget _buildGrid(BuildContext context, Orientation orientation) {
    return StaggeredGridView.extentBuilder(
      primary: false,
      maxCrossAxisExtent: 150,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final image = PostImage(
          imageUrl: post.previewImageUri.toString(),
          //TODO: let the parent widget handle navigation
          onTapped: _handleTap,
        );
        return index >= widget.posts.length ? BottomLoader() : image;
      },
      staggeredTileBuilder: (index) {
        final height = widget.posts[index].height / 10;
        double mainAxisExtent;

        if (height > 150) {
          mainAxisExtent = 150;
        } else if (height < 80) {
          mainAxisExtent = 80;
        } else {
          mainAxisExtent = height;
        }

        return StaggeredTile.extent(1, mainAxisExtent);
      },
      controller: widget.scrollController..addListener(_onScroll),
    );
  }

  void _onScroll() {
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    final currentThresholdPercent = currentScroll / maxScroll;

    if (currentThresholdPercent >= widget.scrollThreshold) {
      widget.onMaxItemReached(null);
    }
  }

  void _handleTap(value) {
    //TODO: use framework
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostListSwipePage(posts: widget.posts),
        ));
  }
}
