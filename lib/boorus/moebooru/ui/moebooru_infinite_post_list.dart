// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_image_legacy.dart';
import 'package:boorusama/core/ui/default_multi_selection_actions.dart';
import 'package:boorusama/core/ui/general_post_context_menu.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/infinite_post_list.dart';
import 'package:boorusama/core/ui/multi_select_controller.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/double_utils.dart';

class MoebooruInfinitePostList extends StatefulWidget {
  const MoebooruInfinitePostList({
    super.key,
    required this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.loading,
    required this.refreshing,
    required this.hasMore,
    this.error,
    required this.data,
  });

  final VoidCallback onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final bool loading;
  final bool refreshing;
  final bool hasMore;
  final BooruError? error;
  final List<Post> data;

  final bool extendBody;
  final double? extendBodyHeight;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  State<MoebooruInfinitePostList> createState() =>
      _MoebooruInfinitePostListState();
}

class _MoebooruInfinitePostListState extends State<MoebooruInfinitePostList> {
  late final AutoScrollController _autoScrollController;
  final _multiSelectController = MultiSelectController<Post>();
  var multiSelect = false;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
    _multiSelectController.addListener(() {
      setState(() {
        multiSelect = _multiSelectController.multiSelectEnabled;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _multiSelectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.imageBorderRadius !=
              current.settings.imageBorderRadius ||
          previous.settings.imageGridSpacing !=
              current.settings.imageGridSpacing ||
          previous.settings.imageQuality != current.settings.imageQuality ||
          previous.settings.imageListType != current.settings.imageListType,
      builder: (context, state) {
        return InfinitePostList(
          scrollController: _autoScrollController,
          sliverHeaderBuilder: widget.sliverHeaderBuilder,
          footerBuilder: (context, selectedItems) =>
              DefaultMultiSelectionActions(
            selectedPosts: selectedItems,
            endMultiSelect: () {
              _multiSelectController.disableMultiSelect();
            },
          ),
          multiSelectController: _multiSelectController,
          onLoadMore: widget.onLoadMore,
          onRefresh: widget.onRefresh,
          hasMore: widget.hasMore,
          itemBuilder: (context, index) {
            final post = widget.data[index];

            return ContextMenuRegion(
              isEnabled: !multiSelect,
              contextMenu: GeneralPostContextMenu(
                hasAccount: false,
                onMultiSelect: () {
                  _multiSelectController.enableMultiSelect();
                },
                post: post,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => ImageGridItem(
                  onTap: !multiSelect
                      ? () {
                          goToMoebooruDetailsPage(
                            context: context,
                            posts: widget.data,
                            initialPage: index,
                            scrollController: _autoScrollController,
                          );
                        }
                      : null,
                  isFaved: false,
                  enableFav: authState is Authenticated,
                  onFavToggle: (isFaved) async {},
                  autoScrollOptions: AutoScrollOptions(
                    controller: _autoScrollController,
                    index: index,
                  ),
                  isAnimated: post.isAnimated,
                  isTranslated: post.isTranslated,
                  hasComments: post.hasComment,
                  hasParentOrChildren: post.hasParentOrChildren,
                  image: state.settings.imageListType == ImageListType.masonry
                      ? Hero(
                          tag: '${post.id}_hero',
                          child: BooruImage(
                            aspectRatio: post.aspectRatio,
                            imageUrl: getImageUrlForDisplay(
                              post,
                              getImageQuality(
                                size: state.settings.gridSize,
                                presetImageQuality: state.settings.imageQuality,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              state.settings.imageBorderRadius,
                            ),
                            placeholderUrl: post.thumbnailImageUrl,
                            previewCacheManager:
                                context.read<PreviewImageCacheManager>(),
                            cacheHeight:
                                (constraints.maxHeight * 2).toIntOrNull(),
                            cacheWidth:
                                (constraints.maxWidth * 2).toIntOrNull(),
                          ),
                        )
                      : Hero(
                          tag: '${post.id}_hero',
                          child: BooruImageLegacy(
                            imageUrl: getImageUrlForDisplay(
                              post,
                              getImageQuality(
                                size: state.settings.gridSize,
                                presetImageQuality: state.settings.imageQuality,
                              ),
                            ),
                            placeholderUrl: post.thumbnailImageUrl,
                            borderRadius: BorderRadius.circular(
                              state.settings.imageBorderRadius,
                            ),
                            cacheHeight:
                                (constraints.maxHeight * 2).toIntOrNull(),
                            cacheWidth:
                                (constraints.maxWidth * 2).toIntOrNull(),
                          ),
                        ),
                ),
              ),
            );
          },
          items: widget.data,
          bodyBuilder: (context, itemBuilder) {
            return SliverPostGrid(
              itemBuilder: itemBuilder,
              settings: state.settings,
              refreshing: widget.refreshing,
              error: widget.error,
              data: widget.data,
            );
          },
          loading: widget.loading,
        );
      },
    );
  }
}
