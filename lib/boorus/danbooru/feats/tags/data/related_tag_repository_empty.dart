// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

class RelatedTagRepositoryEmpty implements RelatedTagRepository {
  @override
  Future<RelatedTag> getRelatedTag(String query) async =>
      RelatedTag(query: query, tags: const []);
}
