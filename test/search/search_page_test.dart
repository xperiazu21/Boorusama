// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/danbooru/config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
import 'common.dart';

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

class MockTagSearchBloc extends MockBloc<TagSearchEvent, TagSearchState>
    implements TagSearchBloc {}

class MockSearchHistoryCubit
    extends MockCubit<AsyncLoadState<List<SearchHistory>>>
    implements SearchHistoryCubit {}

class MockRelatedTagBloc
    extends MockBloc<RelatedTagEvent, AsyncLoadState<RelatedTag>>
    implements RelatedTagBloc {}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockAutocompleteRepository extends Mock
    implements AutocompleteRepository {}

class MockPostRepository extends Mock implements IPostRepository {}

class MockBlacklistedTagRepository extends Mock
    implements BlacklistedTagsRepository {}

Widget _buildSearchPage({
  required SearchBloc searchBloc,
  required TagSearchBloc tagSearchBloc,
  required PostBloc postBloc,
}) {
  final mockSearchHistoryCubit = MockSearchHistoryCubit();
  final mockRelatedTagBloc = MockRelatedTagBloc();
  final mockThemeBloc = MockThemeBloc();
  final mockSettingsCubit = MockSettingsCubit();

  when(() => mockSearchHistoryCubit.state)
      .thenAnswer((_) => const AsyncLoadState<List<SearchHistory>>.initial());
  when(() => mockThemeBloc.state)
      .thenAnswer((_) => const ThemeState(theme: ThemeMode.dark));

  when(() => mockRelatedTagBloc.state)
      .thenAnswer((_) => const AsyncLoadState<RelatedTag>.initial());

  when(() => mockSettingsCubit.state)
      .thenAnswer((_) => SettingsState.defaultSettings());

  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: searchBloc),
        BlocProvider<PostBloc>.value(value: postBloc),
        BlocProvider<TagSearchBloc>.value(value: tagSearchBloc),
        BlocProvider<SearchHistoryCubit>.value(value: mockSearchHistoryCubit),
        BlocProvider<RelatedTagBloc>.value(value: mockRelatedTagBloc),
        BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
      ],
      child: MultiRepositoryProvider(
        providers: [RepositoryProvider<IConfig>.value(value: DanbooruConfig())],
        child: const SearchPage(
          metatags: [],
          metatagHighlightColor: Colors.blueAccent,
        ),
      ),
    ),
  );
}

void main() {
  final mockAutocompleteRepository = MockAutocompleteRepository();
  final mockPostRepository = MockPostRepository();
  final mockBlacklistedTagRepository = MockBlacklistedTagRepository();

  SearchBloc createSearchBloc() => SearchBloc(
      initial: const SearchState(displayState: DisplayState.options));
  TagSearchBloc createTagSearchBloc() => TagSearchBloc(
      autocompleteRepository: mockAutocompleteRepository,
      tagInfo: const TagInfo(metatags: [], defaultBlacklistedTags: []));
  PostBloc createPostBloc() => PostBloc(
        postRepository: mockPostRepository,
        blacklistedTagsRepository: mockBlacklistedTagRepository,
      );

  setUpAll(() {
    when(() => mockAutocompleteRepository.getAutocomplete('a'))
        .thenAnswer((_) => Future.value([autocompleteData('a')]));

    when(() => mockAutocompleteRepository.getAutocomplete('nodata'))
        .thenAnswer((_) => Future.value([]));

    when(() => mockPostRepository.getPosts('nodata ', 1))
        .thenAnswer((_) => Future.value([]));

    when(() => mockPostRepository.getPosts('data ', 1))
        .thenAnswer((_) => Future.value([Post.empty()]));

    when(() => mockBlacklistedTagRepository.getBlacklistedTags())
        .thenAnswer((invocation) => Future.value([]));
  });

  testWidgets(
    'when entering text, suggestion should be shown',
    (tester) async {
      final searchBloc = createSearchBloc();
      await tester.pumpWidget(_buildSearchPage(
        searchBloc: searchBloc,
        tagSearchBloc: createTagSearchBloc(),
        postBloc: createPostBloc(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pumpAndSettle();

      expect(searchBloc.state.displayState, DisplayState.suggestion);
    },
  );

  testWidgets(
    'when deleting text and current text is empty, options should be shown',
    (tester) async {
      final searchBloc = createSearchBloc();

      await tester.pumpWidget(_buildSearchPage(
        searchBloc: searchBloc,
        tagSearchBloc: createTagSearchBloc(),
        postBloc: createPostBloc(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pumpAndSettle();

      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);

      expect(searchBloc.state.displayState, DisplayState.options);
    },
  );

  testWidgets(
    'search a tag will show result',
    (tester) async {
      final searchBloc = createSearchBloc();
      final tagSearchBloc = createTagSearchBloc();

      await tester.pumpWidget(_buildSearchPage(
        searchBloc: searchBloc,
        tagSearchBloc: tagSearchBloc,
        postBloc: createPostBloc(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'data');
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));

      expect(searchBloc.state.displayState, DisplayState.result);
    },
  );
}