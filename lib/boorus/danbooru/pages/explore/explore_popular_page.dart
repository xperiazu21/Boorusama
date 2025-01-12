// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/core/widgets/datetime_selector.dart';
import 'package:boorusama/boorus/core/widgets/time_scale_toggle_switch.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/explores/explore_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/utils/duration_utils.dart';

class ExplorePopularPage extends ConsumerWidget {
  const ExplorePopularPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.explorePopular,
        ),
        builder: (_) => DanbooruProvider(
          builder: (_) => CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                timeScaleProvider.overrideWith((ref) => TimeScale.day),
                dateProvider.overrideWith((ref) => DateTime.now()),
              ],
              child: const ExplorePopularPage(),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAndDate = ref.watch(timeAndDateProvider);

    return DanbooruPostScope(
      fetcher: (page) => ref
          .watch(danbooruExploreRepoProvider)
          .getPopularPosts(timeAndDate.date, page, timeAndDate.scale),
      builder: (context, controller, errors) => _PopularContent(
        controller: controller,
        errors: errors,
      ),
    );
  }
}

class _PopularContent extends ConsumerWidget {
  const _PopularContent({
    required this.controller,
    this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleAndTime = ref.watch(timeAndDateProvider);

    ref.listen(
      timeAndDateProvider,
      (previous, next) async {
        if (previous != next) {
          // Delay 100ms, this is a hack
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return Column(
      children: [
        Expanded(
          child: DanbooruInfinitePostList(
            errors: errors,
            controller: controller,
            sliverHeaderBuilder: (context) => [
              ExploreSliverAppBar(
                title: 'explore.popular'.tr(),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    TimeScaleToggleSwitch(
                      onToggle: (scale) =>
                          ref.read(timeScaleProvider.notifier).state = scale,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: context.theme.bottomNavigationBarTheme.backgroundColor,
          child: DateTimeSelector(
            onDateChanged: (date) =>
                ref.read(dateProvider.notifier).state = date,
            date: scaleAndTime.date,
            scale: scaleAndTime.scale,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
