// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/i_comment_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CommentCubit extends Cubit<AsyncLoadState<List<Comment>>> {
  CommentCubit({
    required this.commentRepository,
    required this.userRepository,
  }) : super(const AsyncLoadState.initial());

  final ICommentRepository commentRepository;
  final IUserRepository userRepository;

  void getComment(int postId) {
    tryAsync<List<Comment>>(
        action: () => commentRepository.getCommentsFromPostId(postId),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (comments) async {
          final dtos = await commentRepository.getCommentsFromPostId(postId);
          final comments = dtos.toList();

          final userList = comments.map((e) => e.creatorId).toSet().toList();
          final users =
              await userRepository.getUsersByIdStringComma(userList.join(','));

          final commentsWithAuthor =
              (comments..sort((a, b) => a.id.compareTo(b.id))).map((comment) {
            final author =
                users.where((user) => user.id.value == comment.creatorId).first;
            return comment.copyWith(author: author);
          }).toList();

          emit(AsyncLoadState.success(commentsWithAuthor));
        });
  }
}
