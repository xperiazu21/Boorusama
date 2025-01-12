// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/widgets/widgets.dart';

class GelbooruPostDetailPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.fullscreen,
    required this.onExit,
    this.hasDetailsTagList = true,
  });

  final int initialIndex;
  final List<Post> posts;
  final bool fullscreen;
  final void Function(int page) onExit;
  final bool hasDetailsTagList;

  static MaterialPageRoute routeOf({
    required Booru booru,
    required Settings settings,
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
  }) {
    return MaterialPageRoute(
      builder: (_) => GelbooruProvider(
        builder: (gcontext) {
          return GelbooruPostDetailPage(
            posts: posts,
            initialIndex: initialIndex,
            onExit: (page) => scrollController?.scrollToIndex(page),
            fullscreen: settings.detailsDisplay == DetailsDisplay.imageFocus,
            hasDetailsTagList: booru.booruType.supportTagDetails,
          );
        },
      ),
    );
  }

  @override
  ConsumerState<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailPage>
    with PostDetailsPageMixin<GelbooruPostDetailPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<Post> get posts => widget.posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: onSwiped,
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder<VideoProgress>(
              valueListenable: videoProgress,
              builder: (_, progress, __) =>
                  BooruVideoProgressBar(progress: progress),
            ),
          GelbooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailImageUrl,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets =
            _buildWidgets(context, expanded, page, currentPage, ref);
        final artists =
            ref.watch(booruPostDetailsArtistProvider(posts[page].id));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomScrollView(
            physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
            controller: PageContentScrollController.of(context),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widgets[index],
                  childCount: widgets.length,
                ),
              ),
              RecommendArtistList(
                onHeaderTap: (index) =>
                    goToGelbooruArtistPage(ref, context, artists[index].tag),
                onTap: (recommendIndex, postIndex) =>
                    goToGelbooruPostDetailsPage(
                  ref: ref,
                  context: context,
                  posts: artists[recommendIndex].posts,
                  initialIndex: postIndex,
                  settings: ref.read(settingsProvider),
                ),
                recommends: artists,
                imageUrl: (item) => item.thumbnailImageUrl,
              )
            ],
          ),
        );
      },
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page, expanded) => [
        GeneralMoreActionButton(post: widget.posts[page]),
      ],
      onExpanded: widget.hasDetailsTagList
          ? (currentPage) => ref.read(tagsProvider.notifier).load(
                posts[currentPage].tags,
                onSuccess: (tags) =>
                    posts[currentPage].loadArtistPostsFrom(ref, tags),
              )
          : null,
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
  ) {
    final theme = ref.watch(themeProvider);
    final post = posts[page];
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
                backgroundColor:
                    theme == ThemeMode.light ? Colors.white : Colors.black,
              )
            : BooruVideo(
                url: post.sampleImageUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
        : InteractiveBooruImage(
            useHero: page == currentPage,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: ref.watch(previewImageCacheManagerProvider),
            width: post.width,
            height: post.height,
            onZoomUpdated: onZoomUpdated,
          );

    return [
      if (!expandedOnCurrentPage)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else if (post.isVideo)
        BooruImage(
          imageUrl: post.thumbnailImageUrl,
          fit: BoxFit.contain,
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        if (widget.hasDetailsTagList)
          TagsTile(
            post: post,
            onTagTap: (tag) =>
                goToGelbooruSearchPage(ref, context, tag: tag.rawName),
          )
        else
          BasicTagList(
            tags: post.tags,
            onTap: (tag) => goToGelbooruSearchPage(ref, context, tag: tag),
          ),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(
          post: post,
        ),
        post.source.whenWeb(
          (source) => SourceSection(source: source),
          () => const SizedBox.shrink(),
        ),
      ],
    ];
  }
}
