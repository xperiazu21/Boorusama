// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

abstract class UserRepository {
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
  Future<User> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}
