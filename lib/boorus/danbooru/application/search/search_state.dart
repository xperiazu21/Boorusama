part of 'search_state_notifier.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @required List<Post> posts,
    @required int page,
    @required SearchMonitoringState monitoringState,
  }) = _SearchState;

  factory SearchState.initial() => SearchState(
        posts: <Post>[],
        page: 1,
        monitoringState: SearchMonitoringState.none(),
      );
}

@freezed
abstract class SearchMonitoringState with _$SearchMonitoringState {
  const factory SearchMonitoringState.none() = _Empty;
  const factory SearchMonitoringState.inProgress({
    @required LoadingType loadingType,
  }) = _InProgress;
  const factory SearchMonitoringState.completed() = _Completed;
}

enum LoadingType {
  refresh,
  more,
}