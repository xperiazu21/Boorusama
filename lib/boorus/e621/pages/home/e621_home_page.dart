// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/e621/pages/home/e621_bottom_bar.dart';
import 'package:boorusama/boorus/e621/pages/popular/e621_popular_page.dart';
import 'package:boorusama/boorus/e621/router.dart';
import 'package:boorusama/boorus/e621/widgets/e621_infinite_post_list.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'e621_other_features_page.dart';

class E621HomePage extends ConsumerStatefulWidget {
  const E621HomePage({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  ConsumerState<E621HomePage> createState() => _E621HomePageState();
}

class _E621HomePageState extends ConsumerState<E621HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final viewIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final auth = ref.watch(authenticationProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme == ThemeMode.light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: viewIndex,
                builder: (context, index, _) => AnimatedIndexedStack(
                  index: index,
                  children: [
                    PostScope(
                      fetcher: (page) =>
                          ref.read(e621PostRepoProvider).getPosts('', page),
                      builder: (context, controller, errors) =>
                          E621InfinitePostList(
                        errors: errors,
                        controller: controller,
                        sliverHeaderBuilder: (context) => [
                          SliverAppBar(
                            backgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            toolbarHeight: kToolbarHeight * 1.2,
                            title: HomeSearchBar(
                              onMenuTap: widget.onMenuTap,
                              onTap: () => goToE621SearchPage(context),
                            ),
                            floating: true,
                            snap: true,
                            automaticallyImplyLeading: false,
                          ),
                        ],
                      ),
                    ),
                    const E621PopularPage(),
                    const E621OtherFeaturesPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: E621BottomBar(
          initialValue: viewIndex.value,
          onTabChanged: (value) => viewIndex.value = value,
          isAuthenticated: auth.isAuthenticated,
        ),
      ),
    );
  }
}
