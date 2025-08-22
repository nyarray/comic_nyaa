import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchView extends ConsumerWidget {
  final void Function()? onClose;
  final void Function(String query)? onSearch;
  SearchView({this.onClose, this.onSearch, super.key});
  bool _isInited = false;
  String _onSuggestQuery(String query, [String? suggest]) {
    print('MainView::_onSuggestQuery ==> query: $query, suggest: $suggest');
    if (suggest != null) {
      int lastWordIndex = query.lastIndexOf(' ');
      lastWordIndex = lastWordIndex > 0 ? lastWordIndex : 0;
      query = query.substring(0, query.lastIndexOf(' ') + 1) + suggest;
    }
    return query;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SearchController controller = SearchController();
    return Container(
        // color: Colors.white,
        child: Column(children: [
      SearchAnchor(
        searchController: controller,
          // isFullScreen: true,
          viewOnChanged: (value) {},
          viewTrailing: [
            InkWell(
                child: const Icon(Icons.search),
                onTap: () => onSearch?.call(controller.text))
          ],
          builder: (BuildContext context, SearchController controller) {
            // controller.addListener(listener)
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (!_isInited) {
                _isInited = true;
                if (!controller.isOpen) controller.openView();
              }
            });
            return SearchBar(
                autoFocus: true,
                onTapOutside: (event) {
                  onClose?.call();
                  print('EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
                },
                onTap: () => controller.openView(),
                leading: const Icon(Icons.search),
                trailing: [
                  // InkWell(
                  //     child: const Icon(Icons.close),
                  //     onTap: () => onClose?.call())
                ]);
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) =>
                  List.generate(5, (i) => Text("Test ${i}")))
    ]));
  }
}

// Column(children: [
//       Padding(
//           padding: EdgeInsets.fromLTRB(8, topPadding, 8, 0),
//           child: SearchAnchor(
//               // viewLeading: const Text('todo'),
//               searchController: controller,
//               viewHintText: 'Input...',
//               viewOnChanged: (query) async {
//                 print('QUERY: $query');
//                 _keywords = query;
//                 const limit = 20;
//                 final lastWordIndex = query.lastIndexOf(' ');
//                 final word = query
//                     .substring(lastWordIndex > 0 ? lastWordIndex : 0)
//                     .trim();
//                 print('QUERY: $word');
//                 final result = await SearchAutoSuggest.instance
//                     .queryAutoSuggest(word, limit: limit);
//                 print('RESULT:: $result');
//                 setState(() => _autoSuggest = result);
//               },
//               // viewOnSubmitted: (query) {
//               //   _keywords = query;
//               //   _onSearch(_keywords);
//               //
//               // },
//               builder: (BuildContext context, SearchController controller) {
//                 return SearchBar(
//                     hintText: 'Search...',
//                     controller: controller,
//                     onChanged: (query) {
//                       controller.openView();
//                     },
//                     onTap: () => controller.openView(),
//                     leading: Row(children: [
//                       InkWell(
//                           onTap: () => {globalKey.currentState?.openDrawer()},
//                           child: const Icon(Icons.menu, color: Colors.black)),
//                       InkWell(
//                         onTap: () => {globalKey.currentState?.openEndDrawer()},
//                         child: SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: SimpleNetworkImage(
//                                 _currentTab?.site.icon ?? '',
//                                 error: Text(
//                                   _currentTab?.site.name?.substring(0, 1) ?? '',
//                                   style: TextStyle(
//                                       fontFamily: AppConfig.uiFontFamily,
//                                       fontSize: 18,
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .secondary),
//                                 ))),
//                       )
//                     ]));
//               },
//               suggestionsBuilder:
//                   (BuildContext context, SearchController controller) {
//                 return _autoSuggest
//                     .map(
//                       (suggest) => ListTile(
//                         minLeadingWidth: 16,
//                         dense: true,
//                         visualDensity: VisualDensity.compact,
//                         onTap: () {
//                           final kwd = _onSuggestQuery(_keywords, suggest.label);
//                           _onSearch(kwd);
//                           // controller.text = kwd;
//                           controller.value = TextEditingValue(text: kwd);
//                           controller.closeView(kwd);
//                         },
//                         leading: const Icon(
//                           Icons.search,
//                         ),
//                         title: Text(
//                           suggest.label,
//                           style: TextStyle(
//                               fontFamily: AppConfig.uiFontFamily,
//                               fontSize: 16,
//                               color: suggest.type != null
//                                   ? ColorUtil.fromHex(suggest.type!.color)
//                                   : null),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         subtitle:
//                             suggest.alias != null && suggest.alias!.isNotEmpty
//                                 ? MarqueeWidget(
//                                     child: Text(
//                                     suggest.alias!.replaceAll(',', ', '),
//                                     style: const TextStyle(
//                                         fontFamily: AppConfig.uiFontFamily,
//                                         fontSize: 14,
//                                         color: Colors.black54),
//                                   ))
//                                 : null,
//                         trailing:
//                             Row(mainAxisSize: MainAxisSize.min, children: [
//                           NyaaTagItem(
//                               text: suggest.type?.name ?? '',
//                               textStyle: const TextStyle(
//                                   fontSize: 12, color: Colors.white),
//                               color: suggest.type != null
//                                   ? ColorUtil.fromHex(suggest.type!.color)
//                                   : null,
//                               isRounded: true),
//                           InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   final text = _onSuggestQuery(
//                                       controller.text, suggest.label);

//                                   controller.text = text;
//                                 });

//                                 // _floatingSearchBarController.query =
//                                 //     _onSuggestQuery(
//                                 //         _floatingSearchBarController.query,
//                                 //         suggest.label);
//                               },
//                               child: const Icon(
//                                 Icons.add,
//                                 size: 32,
//                               )),
//                         ]),
//                       ),
//                     )
//                     .toList();
//               }))
//     ]);
