// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'danbooru_post.dart';

typedef DanbooruPostsOrError = PostsOrErrorCore<DanbooruPost>;

abstract class DanbooruPostRepository implements PostRepository {
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
  });
  DanbooruPostsOrError getPostsFromIds(List<int> ids);
}

mixin DanbooruPostRepositoryMixin {
  DanbooruPostRepository get postRepository;

  Future<List<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository.getPosts(tags, page).run().then((value) => value.fold(
            (l) => <DanbooruPost>[],
            (r) => r,
          ));
}
