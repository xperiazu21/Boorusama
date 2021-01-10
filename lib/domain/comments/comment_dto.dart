import 'package:freezed_annotation/freezed_annotation.dart';

import 'comment.dart';

part 'comment_dto.freezed.dart';
part 'comment_dto.g.dart';

@freezed
abstract class CommentDto with _$CommentDto {
  const factory CommentDto({
    int id,
    // ignore: non_constant_identifier_names
    String created_at,
    // ignore: non_constant_identifier_names
    int post_id,
    // ignore: non_constant_identifier_names
    int creator_id,
    String body,
    int score,
    // ignore: non_constant_identifier_names
    String updated_at,
    // ignore: non_constant_identifier_names
    int updater_id,
    // ignore: non_constant_identifier_names
    bool do_not_bump_post,
    // ignore: non_constant_identifier_names
    bool is_deleted,
    // ignore: non_constant_identifier_names
    bool is_sticky,
  }) = _CommentDto;

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);
}

extension CommentDtoX on CommentDto {
  Comment toEntity() {
    return Comment(
      id: id,
      createdAt: DateTime.parse(created_at),
      postId: post_id,
      creatorId: creator_id,
      body: body,
      score: score,
      updatedAt: updated_at,
      updaterId: updater_id,
      isDeleted: is_deleted,
    );
  }
}