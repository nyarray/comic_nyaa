/*
 * Copyright (C) 2022. TsukiSeele
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:comic_nyaa/utils/fixed_queue.dart';
import 'package:comic_nyaa/utils/message.dart';
import 'package:comic_nyaa/views/search_view.dart';
import 'package:comic_nyaa/widget/back_control.dart';
import 'package:comic_nyaa/views/drawer/nyaa_end_drawer.dart';
import 'package:comic_nyaa/widget/empty_data.dart';
import 'package:flutter/material.dart';
import 'package:comic_nyaa/library/mio/model/site.dart';
import 'package:comic_nyaa/library/mio/core/site_manager.dart';
import 'package:comic_nyaa/app/app_config.dart';
import 'package:comic_nyaa/data/download/nyaa_download_manager.dart';
import 'package:comic_nyaa/models/typed_model.dart';
import 'package:comic_nyaa/views/pages/gallery_view.dart';

import 'package:comic_nyaa/data/subscribe/subscribe_manager.dart';
import 'package:comic_nyaa/views/drawer/nyaa_drawer.dart';

class MainView extends StatefulWidget {
  const MainView(
      {Key? key, this.site, this.keywords, this.enableBackControl = false})
      : super(key: key);
  final Site? site;
  final String? keywords;
  final bool enableBackControl;

  @override
  State<MainView> createState() => MainViewState();
}

class MainViewState extends State<MainView> with TickerProviderStateMixin {
  final globalKey = GlobalKey<ScaffoldState>();

  // final FloatingSearchBarController _floatingSearchBarController =
  //     FloatingSearchBarController();
  final RecyclerQueue<GalleryView> _viewQueue = RecyclerQueue(3);
  ScrollController? _viewScrollController;
  List<Site> _sites = [];
  // List<Tag> _autoSuggest = [];
  int _lastScrollPosition = 0;
  // String _keywords = '';
  bool _isSearching = false;

  final _tabColors = [
    Colors.teal,
    Colors.amber,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.pink,
  ];

  GalleryView? get _view {
    return _viewQueue.isNotEmpty ? _viewQueue.last : null;
  }

  void _newView(Site site) {
    setState(() {
      _viewQueue.add(_buildView(site));
    });
  }

  Future<void> _initialize() async {
    await _checkPluginsUpdate();
    setState(() {
      _sites = SiteManager.sites.values.toList();
      // 打开默认标签
      if (widget.site != null) {
        _newView(widget.site!);
      } else {
        _newView(
            _sites.firstWhereOrNull((site) => site.id == 920) ?? _sites[0]);
      }

      _listenGalleryScroll();
      _view?.controller.onItemSelect = _onGalleryItemSelected;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.keywords != null) {
        _onSearch(widget.keywords!);
      }
    });
  }

  Future<void> _checkPluginsUpdate() async {
    final ruleDir = (await AppConfig.ruleDir);
    await SiteManager.loadFromDirectory(ruleDir);
    if (SiteManager.sites.isEmpty) {
      await (await SubscribeManager.instance).updateAllSubscribe();
    }
  }

  Future<void> downloadSelections() async {
    List<TypedModel> items = _view!.controller.selects.values.toList();
    Message.show(msg: '${items.length}个任务已添加');

    (await NyaaDownloadManager.instance).addAll(items);
    setState(() {
      _view?.controller.clearSelection();
    });
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _listenGalleryScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Remove old scroll listener
        // for (var item in _galleryList) {
        //   item.controller.scrollController?.removeListener(_onGalleryScroll);
        // }
        _viewScrollController = _view?.controller.scrollController;
        if (_viewScrollController == null) return;
        _onGalleryScroll();
        _viewScrollController!.addListener(_onGalleryScroll);
      }
    });
  }

  void _onGalleryScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewScrollController == null ||
          _viewScrollController?.positions.isNotEmpty != true) {
        return;
      }
      if (_viewScrollController!.position.pixels < 128) {
        // _floatingSearchBarController.isHidden
        //     ? _floatingSearchBarController.show()
        //     : null;
      } else if (_viewScrollController!.position.pixels >
          _lastScrollPosition + 64) {
        _lastScrollPosition = _viewScrollController!.position.pixels.toInt();
        // _floatingSearchBarController.isVisible
        //     ? _floatingSearchBarController.hide()
        //     : null;
      } else if (_viewScrollController!.position.pixels <
          _lastScrollPosition - 64) {
        _lastScrollPosition = _viewScrollController!.position.pixels.toInt();
        // _floatingSearchBarController.isHidden
        //     ? _floatingSearchBarController.show()
        //     : null;
      }
    });
  }

  void _onGalleryItemSelected(Map<int, TypedModel> selects) {
    setState(() {});
  }

  void _onSearch(String query) async {
    // _floatingSearchBarController.close();
    _view?.controller.search?.call(query);
    // setState(() => _floatingSearchBarController.query = query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      // appBar: _buildAppBar(),
      drawerEdgeDragWidth: 64,
      drawerEnableOpenDragGesture: true,
      endDrawerEnableOpenDragGesture: true,
      resizeToAvoidBottomInset: false,
      drawer: const NyaaDrawer(),
      endDrawer: _buildEndDrawer(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: widget.enableBackControl
          ? BackControl(child: _buildMain(), onBack: () => !_onBackPress())
          : _buildMain(),
    );
  }

  Widget _buildEndDrawer() {
    return NyaaEndDrawer(
      sites: _sites,
      onItemTap: (site) {
        _newView(site);
        setState(() => _view);
        globalKey.currentState?.closeEndDrawer();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_view?.site.name ?? 'ComicNyaa'),
      leading: InkWell(
          child: const Icon(Icons.search),
          onTap: () => setState(() {
                _isSearching = !_isSearching;
              })
          // onTap: () => RouteUtil.push(context, _buildFloatingSearchBar()),
          ),
      actions: [
      ],
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        // Stack(children: [ _buildFloatingSearchBar(), _buildAppBar()]),
        _isSearching ? _buildFloatingSearchBar() : _buildAppBar(),
        _view ?? Container()
      ],
    );
  }

  GalleryView _buildView(Site site) {
    final color = Colors.white;
    return GalleryView(
      site: site,
      heroKey: site.id.toString(),
      // color: color,
      empty: EmptyData(
        text: '无可用数据',
        color: color,
        textColor: color,
      ),
    );
  }

  Widget _buildFab() {
    return Container(
        margin: const EdgeInsets.only(bottom: 48),
        child: _view?.controller.selects.isEmpty == true
            ? FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () => _view?.controller.scrollController?.animateTo(
                    0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.ease),
                tooltip: 'Top',
                child: const Icon(Icons.arrow_upward),
              )
            : FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  downloadSelections();
                },
                tooltip: 'Download',
                child: const Icon(Icons.download),
              ));
  }

  Widget _buildFloatingSearchBar() {
    // final isPortrait =
    // MediaQuery.of(context).orientation == Orientation.portrait;
    // final topPadding = MediaQuery.of(context).padding.top;
    // final controller = SearchController();
    return SearchView(onClose: () => setState(() => _isSearching = false), onSearch: (query) {
      _onSearch(query);
    },);

    // FloatingSearchBar(
    //     controller: _floatingSearchBarController,
    //     automaticallyImplyDrawerHamburger: false,
    //     automaticallyImplyBackButton: false,
    //     hint: 'Search...',
    //     scrollPadding: const EdgeInsets.only(top: 8, bottom: 8),
    //     // implicitDuration: const Duration(milliseconds: 250),
    //     transitionDuration: const Duration(milliseconds: 200),
    //     debounceDelay: const Duration(milliseconds: 500),
    //     transitionCurve: Curves.easeInOut,
    //     // physics: const BouncingScrollPhysics(),
    //     axisAlignment: isPortrait ? 0.0 : -1.0,
    //     openAxisAlignment: 0.0,
    //     width: isPortrait ? 600 : 500,
    //     clearQueryOnClose: false,
    //     closeOnBaTkdropTap: true,
    //     hintStyle: const TextStyle(
    //         fontFamily: AppConfig.uiFontFamily,
    //         fontSize: 16,
    //         color: Colors.black26),
    //     queryStyle:
    //         const TextStyle(fontFamily: AppConfig.uiFontFamily, fontSize: 16),
    //     onQueryChanged: (query) async {
    //       _keywords = query;
    //       const limit = 20;
    //       final lastWordIndex = query.lastIndexOf(' ');
    //       final word =
    //           query.substring(lastWordIndex > 0 ? lastWordIndex : 0).trim();
    //       // print('QUERY: $word');
    //       final autosuggest = await SearchAutoSuggest.instance
    //           .queryAutoSuggest(word, limit: limit);
    //       // print('RESULT:: $autosuggest');
    //       setState(() =>  = autosuggest);
    //     },
    //     transition: CircularFloatingSearchBarTransition(),
    //     leadingActions: [
    //       FloatingSearchBarAction.hamburgerToBack(),
    //       FloatingSearchBarAction(
    //           showIfOpened: true,
    //           child: SizedBox(
    //               width: 24,
    //               height: 24,
    //               child: SimpleNetworkImage(_currentTab?.site.icon ?? '',
    //                   error: Text(
    //                     _currentTab?.site.name?.substring(0, 1) ?? '',
    //                     style: const TextStyle(
    //                         fontFamily: AppConfig.uiFontFamily,
    //                         fontSize: 18,
    //                         color: Colors.teal),
    //                   )))),
    //     ],
    //     actions: [
    //       FloatingSearchBarAction(
    //         showIfOpened: false,
    //         child: CircularButton(
    //           icon: const Icon(Icons.send_time_extension),
    //           onPressed: () => globalKey.currentState?.openEndDrawer(),
    //         ),
    //       ),
    //       FloatingSearchBarAction.searchToClear(
    //         showIfClosed: false,
    //       ),
    //     ],
    //     onSubmitted: (query) => _onSearch(query),
    //     onFocusChanged: (isFocus) {
    //       if (!isFocus) {
    //         if (_floatingSearchBarController.query !=
    //             _currentTab?.controller.keywords) {
    //           setState(() => _floatingSearchBarController.query =
    //               _currentTab?.controller.keywords ?? '');
    //         }
    //       }
    //     },
    //     builder: (context, transition) => Material(
    //           color: Colors.white,
    //           elevation: 4.0,
    //           borderRadius: BorderRadius.circular(4),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: _autosuggest
    //                 .map(
    //                   (suggest) => ListTile(
    //                     minLeadingWidth: 16,
    //                     dense: true,
    //                     visualDensity: VisualDensity.compact,
    //                     onTap: () => _onSearch(
    //                         _onSuggestQuery(_keywords, suggest.label)),
    //                     leading: const Icon(
    //                       Icons.search,
    //                     ),
    //                     title: Text(
    //                       suggest.label,
    //                       style: TextStyle(
    //                           fontFamily: AppConfig.uiFontFamily,
    //                           fontSize: 16,
    //                           color: suggest.type != null
    //                               ? ColorUtil.fromHex(suggest.type!.color)
    //                               : null),
    //                       maxLines: 1,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                     subtitle:
    //                         suggest.alias != null && suggest.alias!.isNotEmpty
    //                             ? MarqueeWidget(
    //                                 child: Text(
    //                                 suggest.alias!.replaceAll(',', ', '),
    //                                 style: const TextStyle(
    //                                     fontFamily: AppConfig.uiFontFamily,
    //                                     fontSize: 14,
    //                                     color: Colors.black54),
    //                               ))
    //                             : null,
    //                     trailing:
    //                         Row(mainAxisSize: MainAxisSize.min, children: [
    //                       NyaaTagItem(
    //                           text: suggest.type?.name ?? '',
    //                           textStyle: const TextStyle(
    //                               fontSize: 12, color: Colors.white),
    //                           color: suggest.type != null
    //                               ? ColorUtil.fromHex(suggest.type!.color)
    //                               : null,
    //                           isRounded: true),
    //                       InkWell(
    //                           onTap: () {
    //                             _floatingSearchBarController.query =
    //                                 _onSuggestQuery(
    //                                     _floatingSearchBarController.query,
    //                                     suggest.label);
    //                           },
    //                           child: const Icon(
    //                             Icons.add,
    //                             size: 32,
    //                           )),
    //                     ]),
    //                   ),
    //                 )
    //                 .toList(),
    //           ),
    //         ));
  }

  bool _onBackPress() {
    final ScaffoldState state = globalKey.currentState!;
    // if (_floatingSearchBarController.isOpen) {
    //   _floatingSearchBarController.close();
    //   return true;
    // }
    if (state.isDrawerOpen == true) {
      state.closeDrawer();
      return true;
    }
    if (state.isEndDrawerOpen == true) {
      state.closeEndDrawer();
      return true;
    }
    return false;
  }
}
