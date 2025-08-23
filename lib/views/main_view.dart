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
import 'package:comic_nyaa/widget/simple_network_image.dart';
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
  final RecyclerQueue<GalleryView> _viewQueue = RecyclerQueue(1);
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
    _view?.controller.search?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: _buildAppBar(),
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
      title: Row(children: [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SimpleNetworkImage(_view?.site.icon ?? '')),
        Text(_view?.site.name ?? 'ComicNyaa')
      ]),
      actions: [
        _buildFloatingSearchBar(),
        IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => globalKey.currentState?.openEndDrawer())
      ],
    );
  }

  Widget _buildMain() {
    return _view ?? Container();
  }

  GalleryView _buildView(Site site) {
    const color = Colors.white;
    return GalleryView(
      site: site,
      heroKey: site.id.toString(),
      // color: color,
      empty: const EmptyData(
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
    final controller = SearchController();
    return SearchView(
      iconBuilder: (context, controller) => IconButton(
        // constraints: const BoxConstraints.expand(),
        alignment: Alignment.center,
          onPressed: () => controller.openView(),
          icon: const Icon(Icons.search)),
      controller: controller,
      onClose: () => setState(() => _isSearching = false),
      onSearch: (query) {
        _onSearch(query);
      },
    );
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
