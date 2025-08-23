import 'dart:async';
import 'package:comic_nyaa/data/tags/tags_autosuggest.dart';
import 'package:comic_nyaa/library/mio/model/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchView extends ConsumerWidget {
  final void Function()? onClose;
  final void Function(String query)? onSearch;
  final Widget Function(BuildContext, SearchController) iconBuilder;
  final SearchController controller;
  const SearchView(
      {required this.iconBuilder,
      required this.controller,
      this.onClose,
      this.onSearch,
      super.key});

  // String _onSuggestQuery(String query, [String? suggest]) {
  //   print('MainView::_onSuggestQuery ==> query: $query, suggest: $suggest');
  //   if (suggest != null) {
  //     int lastWordIndex = query.lastIndexOf(' ');
  //     lastWordIndex = lastWordIndex > 0 ? lastWordIndex : 0;
  //     query = query.substring(0, query.lastIndexOf(' ') + 1) + suggest;
  //   }
  //   return query;
  // }

  FutureOr<List<Tag>> _queryAutoSuggest(String query) async {
    const limit = 20;
    final lastWordIndex = query.lastIndexOf(' ');
    final word = query.substring(lastWordIndex > 0 ? lastWordIndex : 0).trim();
    final autosuggest =
        await SearchAutoSuggest.instance.queryAutoSuggest(word, limit: limit);
    return autosuggest;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        alignment: Alignment.center,
        child: SearchAnchor(
            searchController: controller,
            viewOnChanged: (value) {},
            viewTrailing: [
              InkWell(
                  child: const Icon(Icons.search),
                  onTap: () => onSearch?.call(controller.text))
            ],
            builder: iconBuilder,
            suggestionsBuilder:
                (BuildContext context, SearchController controller) async {
              final autoSuggest = await _queryAutoSuggest(controller.text);
              return autoSuggest.map((item) {
                return ListTile(
                  title: Text(item.label),
                  onTap: () {
                    controller.closeView(item.label);
                    onSearch?.call(item.label);
                  },
                );
              });
            }));
  }
}
