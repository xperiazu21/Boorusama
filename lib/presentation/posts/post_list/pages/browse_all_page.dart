import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/pages/refreshable_list.dart';
import 'package:boorusama/presentation/services/debouncer/debouncer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BrowseAllPage extends StatefulWidget {
  BrowseAllPage({
    Key key,
  }) : super(key: key);

  @override
  _BrowseAllPageState createState() => _BrowseAllPageState();
}

class _BrowseAllPageState extends State<BrowseAllPage>
    with AutomaticKeepAliveClientMixin {
  final List<Post> _posts = List<Post>();
  final ScrollController _scrollController = new ScrollController();
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 1));
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _currentPage = 1;
  String _currentSearchQuery = "";

  @override
  void initState() {
    super.initState();
    context
        .read<PostSearchBloc>()
        .add(PostSearchEvent.postSearched(query: "", page: 1));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildList();
  }

  void _handleSearched(String query) {
    _currentSearchQuery = query;
    // _currentPage = 1;
    // _posts.clear();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _assignTagQuery(String query) {
    _currentSearchQuery = query;
  }

  Widget buildList() {
    return BlocListener<PostSearchBloc, PostSearchState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: (query, page) {
            _handleSearched(query);
          },
          success: (posts, query, page) => _assignTagQuery(query),
          error: (error, message) {
            var flush;
            flush = Flushbar(
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
              leftBarIndicatorColor: Theme.of(context).accentColor,
              title: error,
              message: message,
              mainButton: FlatButton(
                onPressed: () {
                  flush.dismiss(true);

                  context
                      .read<PostSearchBloc>()
                      .add(PostSearchEvent.postSearched(query: "", page: 1));
                },
                child: Text("OK"),
              ),
            )..show(context);
          },
        );
      },
      child: BlocListener<PostListBloc, PostListState>(
        listener: (context, state) {
          state.maybeWhen(
            fetched: (posts) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0.0);
              }

              setState(() {
                _posts.clear();
                _posts.addAll(posts);
              });
            },
            fetchedMore: (posts) {
              setState(() {
                _posts.addAll(posts);
                _refreshController.loadComplete();
              });
            },
            orElse: () {},
          );
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _downloadAllPosts,
            child: Icon(Icons.download_sharp),
          ),
          body: RefreshableList(
            posts: _posts,
            onLoadMore: () => _loadMorePosts(),
            onRefresh: () => BlocProvider.of<PostSearchBloc>(context).add(
                PostSearchEvent.postSearched(
                    query: _currentSearchQuery, page: 1)),
            refreshController: _refreshController,
          ),
        ),
      ),
    );
  }

  void _loadMorePosts() {
    _debouncer(() {
      _currentPage++;
      context.read<PostSearchBloc>().add(PostSearchEvent.postSearched(
          query: _currentSearchQuery, page: _currentPage));
    });
  }

  @override
  bool get wantKeepAlive => true;

  void _downloadAllPosts() {
    _posts.forEach((post) {
      context
          .read<PostDownloadBloc>()
          .add(PostDownloadEvent.downloaded(post: post));
    });
  }
}