import 'package:boorusama/boorus/danbooru/application/home/curated/curated_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final _posts = Provider<List<Post>>((ref) {
  return ref.watch(curatedStateNotifierProvider.state).posts;
});
final _curatedPostProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<PostState>((ref) {
  return ref.watch(curatedStateNotifierProvider.state).postsState;
});
final _postsStateProvider = Provider<PostState>((ref) {
  return ref.watch(_postsState);
});

final _timeScale = Provider<TimeScale>((ref) {
  return ref.watch(curatedStateNotifierProvider.state).selectedTimeScale;
});
final _timeScaleProvider = Provider<TimeScale>((ref) {
  final timeScale = ref.watch(_timeScale);

  Future.delayed(
      Duration.zero, () => ref.watch(curatedStateNotifierProvider).refresh());

  return timeScale;
});

final _date = Provider<DateTime>((ref) {
  return ref.watch(curatedStateNotifierProvider.state).selectedDate;
});
final _dateProvider = Provider<DateTime>((ref) {
  final date = ref.watch(_date);

  Future.delayed(
      Duration.zero, () => ref.watch(curatedStateNotifierProvider).refresh());

  return date;
});

class CuratedView extends HookWidget {
  const CuratedView({Key key}) : super(key: key);

  Widget _buildModalTimeScalePicker(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(I18n.of(context).dateRangeDay),
              onTap: () => Navigator.of(context).pop(TimeScale.day),
            ),
            ListTile(
              title: Text(I18n.of(context).dateRangeWeek),
              onTap: () => Navigator.of(context).pop(TimeScale.week),
            ),
            ListTile(
              title: Text(I18n.of(context).dateRangeMonth),
              onTap: () => Navigator.of(context).pop(TimeScale.month),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
    final scrollController = useScrollController();
    final refreshController =
        useState(RefreshController(initialRefresh: false));

    final selectedDate = useProvider(_dateProvider);
    final selectedTimeScale = useProvider(_timeScaleProvider);
    final posts = useProvider(_curatedPostProvider);
    final postsState = useProvider(_postsStateProvider);

    useEffect(() {
      Future.microtask(
          () => context.read(curatedStateNotifierProvider).refresh());
      return () => {};
    }, []);

    return ProviderListener<PostState>(
      provider: _postsState,
      onChange: (context, state) {
        state.maybeWhen(
          fetched: () {
            refreshController.value.loadComplete();
            refreshController.value.refreshCompleted();
          },
          error: () => Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Something went wrong"))),
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => context.read(curatedStateNotifierProvider).refresh(),
        onLoading: () =>
            context.read(curatedStateNotifierProvider).getMorePosts(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonBar(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_left),
                            onPressed: () => context
                                .read(curatedStateNotifierProvider)
                                .reverseOneTimeUnit(),
                          ),
                          FlatButton(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            onPressed: () => DatePicker.showDatePicker(
                              context,
                              theme: DatePickerTheme(),
                              onConfirm: (time) {
                                context
                                    .read(curatedStateNotifierProvider)
                                    .updateDate(time);
                              },
                              currentTime: DateTime.now(),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                    "${DateFormat('MMM d, yyyy').format(selectedDate)}"),
                                Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () => context
                                .read(curatedStateNotifierProvider)
                                .forwardOneTimeUnit(),
                          ),
                        ],
                      ),
                      FlatButton(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () async {
                          final timeScale = await showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context, controller) =>
                                      _buildModalTimeScalePicker(context)) ??
                              selectedTimeScale;

                          context
                              .read(curatedStateNotifierProvider)
                              .updateTimeScale(timeScale);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                                "${selectedTimeScale.toString().split('.').last.toUpperCase()}"),
                            Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            postsState.maybeWhen(
              refreshing: () =>
                  SliverPostGridPlaceHolder(scrollController: scrollController),
              orElse: () => SliverPostGrid(
                key: gridKey.value,
                posts: posts,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}