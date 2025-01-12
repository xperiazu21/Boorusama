// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/notes/note_provider.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/e621/feats/autocomplete/e621_autocomplete_provider.dart';
import 'package:boorusama/boorus/e621/feats/notes/notes.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';

class E621Provider extends StatelessWidget {
  const E621Provider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        postRepoProvider.overrideWith((ref) => ref.watch(e621PostRepoProvider)),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(e621DownloadFileNameGeneratorProvider)),
        autocompleteRepoProvider
            .overrideWith((ref) => ref.watch(e621AutocompleteRepoProvider)),
        noteRepoProvider.overrideWith((ref) => ref.watch(e621NoteRepoProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final e621ApiProvider = Provider<E621Api>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));
  return E621Api(dio);
});

final e621DownloadFileNameGeneratorProvider =
    Provider<FileNameGenerator<Post>>((ref) {
  return Md5OnlyFileNameGenerator();
});
