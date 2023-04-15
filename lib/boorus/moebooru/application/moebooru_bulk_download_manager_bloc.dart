// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/boorus/moebooru/application/moebooru_bulk_post_download_bloc.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/downloads.dart';

class MoebooruBulkDownloadManagerBloc
    extends MobileBulkDownloadManagerBloc<Post> {
  MoebooruBulkDownloadManagerBloc({
    required BuildContext context,
    required super.deviceInfo,
  }) : super(
            bulkPostDownloadBloc: MoebooruBulkPostDownloadBloc(
          downloader: CrossplatformBulkDownloader<Post>(
            userAgentGenerator: context.read<UserAgentGenerator>(),
            urlResolver: (item) => item.downloadUrl,
            fileNameResolver: (item) =>
                Md5OnlyFileNameGenerator().generateFor(item),
            idResolver: (items) => items.id,
          ),
          postRepository: context.read<PostRepository>(),
          errorTranslator: translateBooruError,
          onDownloadDone: (path) => MediaScanner.loadMedia(path: path),
        ));
}
