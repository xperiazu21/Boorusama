// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

final e621PostRepoProvider = Provider<E621PostRepositoryApi>((ref) {
  return E621PostRepositoryApi(
    ref.watch(e621ApiProvider),
    ref.watch(currentBooruConfigProvider),
    ref.watch(settingsRepoProvider),
    ref.watch(globalBlacklistedTagRepoProvider),
  );
});

final e621PopularPostRepoProvider = Provider<E621PopularRepository>((ref) {
  return E621PopularRepositoryApi(
    ref.watch(e621ApiProvider),
    ref.watch(currentBooruConfigProvider),
    ref.watch(settingsRepoProvider),
    ref.watch(globalBlacklistedTagRepoProvider),
  );
});
