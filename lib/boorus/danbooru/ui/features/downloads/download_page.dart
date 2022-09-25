// // Flutter imports:
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// // Project imports:
// import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
// import 'package:boorusama/boorus/danbooru/infra/repositories/posts/post_repository.dart';
// import 'package:boorusama/boorus/danbooru/infra/repositories/tags/tag_repository.dart';
// import 'package:boorusama/boorus/danbooru/infra/services/download_service.dart';
// import 'package:boorusama/boorus/danbooru/ui/shared/search_bar.dart';
// import 'package:boorusama/boorus/danbooru/ui/shared/tag_suggestion_items.dart';

// final _tagsSuggestion = FutureProvider.autoDispose<List<Tag>>((ref) async {
//   final repo = ref.watch(tagProvider);
//   final query = ref.watch(_query);
//   final suggestions = await repo.getTagsByNamePattern(query.state, 1);

//   return suggestions;
// });

// final _query = StateProvider<String>((ref) {
//   return "";
// });

// class DownloadPage extends HookWidget {
//   const DownloadPage({Key? key}) : super(key: key);
//   final maxPage = 10.0;

//   @override
//   Widget build(BuildContext context) {
//     final textEditingController = useTextEditingController();
//     final suggestions = useProvider(_tagsSuggestion);
//     final query = useProvider(_query);
//     final selectedTags = useState(<Tag>[]);
//     final totalPage = useState(1.0);
//     // final sliderValue = useState(totalPage.value / maxPage);

//     // useValueChanged(sliderValue.value, (_, __) {
//     //   totalPage.value = (sliderValue.value * maxPage).roundToDouble();
//     //   print(totalPage.value);
//     // });

//     useEffect(() {
//       if (query.state.isEmpty) {
//         textEditingController.text = "";
//       }

//       return null;
//     }, [query.state]);

//     Widget _buildTags(List<Tag> tags) {
//       return Container(
//         margin: const EdgeInsets.only(left: 8.0),
//         height: 50,
//         child: ListView.builder(
//           shrinkWrap: true,
//           scrollDirection: Axis.horizontal,
//           itemCount: tags.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.0),
//               child: Chip(
//                 onDeleted: () => selectedTags.value = [
//                   ...selectedTags.value..remove(tags[index])
//                 ],
//                 backgroundColor: Color(tags[index].tagHexColor),
//                 padding: const EdgeInsets.all(4.0),
//                 labelPadding: const EdgeInsets.all(1.0),
//                 visualDensity: VisualDensity.compact,
//                 label: ConstrainedBox(
//                   constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.85),
//                   child: Text(
//                     tags[index].displayName,
//                     overflow: TextOverflow.fade,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: SearchBar(
//           hintText: "Find some tags to download",
//           onChanged: (value) => query.state = value,
//           queryEditingController: textEditingController,
//           leading: const Icon(Icons.search),
//           trailing: query.state.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => query.state = "",
//                 )
//               : null,
//         ),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               suggestions.maybeWhen(
//                   data: (tags) => Expanded(
//                           child: TagSuggestionItems(
//                         tags: tags,
//                         onItemTap: (value) {
//                           query.state = "";
//                           FocusScope.of(context).unfocus();
//                           selectedTags.value = [...selectedTags.value, value];
//                         },
//                       )),
//                   orElse: () => SizedBox.shrink()),
//             ],
//           ),
//           Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 color: Theme.of(context).canvasColor,
//                 height: MediaQuery.of(context).size.height * 0.25,
//                 child: Column(
//                   children: [
//                     _buildTags(selectedTags.value),
//                     const Text("Total download pages"),
//                     Slider(
//                       min: 1.0,
//                       max: maxPage,
//                       divisions: 10,
//                       label: totalPage.value.round().toString(),
//                       value: totalPage.value,
//                       onChanged: (value) {
//                         totalPage.value = value;
//                       },
//                     ),
//                     Spacer(),
//                     Container(
//                       margin: const EdgeInsets.all(8.0),
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           List.generate(totalPage.value.round(), (index) async {
//                             final posts = await context
//                                 .read(postProvider)
//                                 .getPosts(
//                                     selectedTags.value
//                                         .map((tag) => tag.rawName)
//                                         .toList()
//                                         .join(' '),
//                                     index + 1,
//                                     limit: 100);
//                             posts.forEach((post) {
//                               context
//                                   .read(downloadServiceProvider)
//                                   .download(post);
//                             });
//                           });
//                         },
//                         child: const Text("Download"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ))
//         ],
//       ),
//     );
//   }
// }