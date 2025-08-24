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

import 'package:comic_nyaa/utils/message.dart';
import 'package:comic_nyaa/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:comic_nyaa/library/mio/model/site.dart';
import 'package:comic_nyaa/library/mio/core/mio.dart';
import 'package:comic_nyaa/models/typed_model.dart';
import 'package:comic_nyaa/widget/ink_stack.dart';
import 'package:comic_nyaa/widget/triangle_painter.dart';
import 'package:comic_nyaa/views/detail/image_detail_view.dart';
import 'package:comic_nyaa/views/detail/comic_detail_view.dart';
import 'package:comic_nyaa/views/detail/video_detail_view.dart';
import 'package:comic_nyaa/utils/flutter_utils.dart';

import '../detail/image_detail_view.dart';

class GalleryController {
  String keywords = '';
  List<TypedModel> items = [];
  ScrollController? scrollController;
  Map<int, TypedModel> selects = {};
  ValueChanged<Map<int, TypedModel>>? onItemSelect;
  Future<void>? Function(String keywords)? search;
  Future<void>? Function()? refresh;
  late void Function() clearSelection;
}

class GalleryView extends StatefulWidget {
  GalleryView(
      {Key? key,
      required this.site,
      required this.heroKey,
      this.color,
      this.scrollbarColor,
      this.empty})
      : super(key: key);
  final GalleryController controller = GalleryController();
  final Site site;
  final String heroKey;
  final Color? color;
  final Color? scrollbarColor;
  final Widget? empty;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with AutomaticKeepAliveClientMixin<GalleryView>, TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final Map<int, double> _itemsSizeCache = {};
  final Map<int, TypedModel> _itemsSelected = {};
  List<TypedModel> _items = [];
  List<TypedModel> _itemsPreloaded = [];
  // double _topOffset = 0;
  int _page = 0;
  String _keywords = '';
  bool _isLoading = false;

  Future<void> _initialize() async {
    widget.controller.scrollController = _scrollController;
    widget.controller.refresh = _refreshController.requestRefresh;
    widget.controller.search = (String kwds) async {
      _keywords = kwds;
      await _refreshController.requestRefresh();
    };
    widget.controller.clearSelection = _clearSelections;
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshController.requestRefresh();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          if (!_isLoading) {
            _onNext();
          }
        }
      });
    });
  }

  void _clearSelections() {
    setState(() {
      _itemsSelected.clear();
      widget.controller.onItemSelect?.call(_itemsSelected);
    });
  }

  /// 获取数据
  Future<List<TypedModel>> _requestItems(
      {Site? site, int? page, String? keywords}) async {
    widget.controller.keywords = _keywords;
    site = site ?? _currentSite;
    page = page ?? _page;
    keywords = keywords ?? _keywords;
    final results = await (Mio(site)
          ..setPage(page)
          ..setKeywords(keywords))
        .parseSite();
    return List.of(results.map((item) => TypedModel.fromJson(item)));
  }

  void _reset() {
    setState(() {
      _page = 0;
      _keywords = '';
      _items = [];
      _itemsSizeCache.clear();
      _itemsPreloaded.clear();
      _clearSelections();
    });
  }

  Future<void> _onNext() async {
    if (_isLoading) return;
    _page++;
    try {
      _isLoading = true;
      final items = await _requestItems();
      if (items.isEmpty) {
        Message.show(msg: '已经到底了');
        return;
      }
      // 更新status
      setState(() => _items.addAll(items));
      widget.controller.items = _items;
    } catch (e) {
      Message.show(msg: e.toString());
      // rethrow;
    } finally {
      _refreshController.refreshCompleted();
      _isLoading = false;
    }
  }

  Future<void> _onSearch(String keywords) async {
    _reset();
    _keywords = keywords;
    _onNext();
  }

  _onRefresh() async {
    await _onSearch(_keywords);
  }

  void _jump(int index, String? heroKey) {
    final model = _items[index];
    Widget? target;
    switch (model.$type) {
      case 'image':
        target = ImageDetailView(
            models: _items, heroKey: widget.heroKey, index: index);
        break;
      case 'video':
        target = VideoDetailView(model: model);
        break;
      case 'comic':
        target = ComicDetailView(
            model: model,
            heroKey: heroKey ??
                widget.heroKey + model.toString().hashCode.toString());
        break;
    }
    if (target != null) {
      RouteUtil.push(context, target);
    }
  }

  void _onItemSelect(int index) {
    final item = _items[index];
    setState(() => _itemsSelected.containsKey(index)
        ? _itemsSelected.remove(index)
        : _itemsSelected[index] = item);
    widget.controller.selects = _itemsSelected;
    if (widget.controller.onItemSelect != null) {
      widget.controller.onItemSelect!(_itemsSelected);
    }
  }

  Site? get _currentSite {
    return widget.site;
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // _topOffset = kToolbarHeight + MediaQuery.of(context).viewPadding.top;
    return RawScrollbar(
        controller: _scrollController,
        thickness: 4,
        thumbVisibility: true,
        thumbColor: widget.scrollbarColor ?? widget.color,
        radius: const Radius.circular(4),
        child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropMaterialHeader(
              distance: 48,
              // offset: _topOffset,
              backgroundColor: widget.color ?? Theme.of(context).primaryColor,
            ),
            controller: _refreshController,
            scrollController: _scrollController,
            onRefresh: () => _onRefresh(),
            onLoading: () => _onNext(),
            physics: const BouncingScrollPhysics(),
            // onLoading: _onLoading,
            child: _items.isNotEmpty /*||
                    _refreshController.isLoading ||
                    _refreshController.isRefresh*/
                ? MasonryGridView.count(
                    // padding: EdgeInsets.fromLTRB(8, _topOffset + 8, 8, 0),
                    padding: const EdgeInsets.all(8.0),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    itemCount: _items.length,
                    controller: _scrollController,
                    itemBuilder: _buildItem)
                : widget.empty ??
                    const Center(
                      child: Text(
                        'No data',
                        style: TextStyle(fontSize: 24),
                      ),
                    )));
  }

  Widget _buildItem(context, index) {
    final controller = AnimationController(
        value: 1, duration: const Duration(milliseconds: 250), vsync: this);
    // tabIndex + url + itemIndex
    final coverUrl = _items[index].availableCoverUrl;
    final heroKey = '${widget.heroKey}-$coverUrl-$index';
    _itemsSizeCache[index] ??= 1.33;
    return RepaintBoundary(
        child: Material(
      clipBehavior: Clip.hardEdge,
      shadowColor: Colors.black45,
      elevation: 2,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: InkStack(
        alignment: Alignment.center,
        splashColor: widget.color,
        onTap: () => _itemsSelected.isEmpty
            ? _jump(index, heroKey)
            : _onItemSelect(index),
        onLongPress: () =>
            _itemsSelected.isEmpty ? _onItemSelect(index) : _clearSelections(),
        children: [
          Column(children: [
            Hero(
              tag: heroKey,
              child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: AspectRatio(
                      aspectRatio: _itemsSizeCache[index]!,
                      child: ExtendedImage.network(coverUrl,
                          headers: _currentSite?.headers,
                          opacity: controller,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          retries: 2,
                          timeRetry: const Duration(milliseconds: 500),
                          timeLimit: const Duration(milliseconds: 5000),
                          loadStateChanged: (state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            controller.reset();
                            return Shimmer.fromColors(
                                baseColor:
                                    const Color.fromRGBO(240, 240, 240, 1),
                                highlightColor: Colors.white,
                                child: AspectRatio(
                                  aspectRatio: 0.66,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                  ),
                                ));
                          case LoadState.failed:
                            return const AspectRatio(
                                aspectRatio: 0.66,
                                child:
                                    Icon(Icons.image_not_supported, size: 32));
                          case LoadState.completed:
                            controller.forward();
                            return null;
                        }
                      }, afterPaintImage: (canvas, rect, image, paint) {
                        WidgetsBinding.instance.addPostFrameCallback((t) {
                          setState(() {
                            _itemsSizeCache[index] = image.width / image.height;
                          });
                        });
                        // _heightCache[index] = rect.height;
                      }))),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _items[index].title ?? '',
                maxLines: 3,
              ),
            ),
          ]),
          _itemsSelected.containsKey(index)
              ? Positioned.fill(
                  child: Container(
                      color: widget.color?.withValues(alpha: .33),
                      alignment: Alignment.bottomRight,
                      child: triangle(
                        width: 32,
                        height: 32,
                        color: widget.color ?? Theme.of(context).primaryColor,
                        direction: TriangleDirection.bottomRight,
                        contentAlignment: Alignment.bottomRight,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      )))
              : Container(),
        ],
      ),
    ));
  }

  @override
  void didUpdateWidget(covariant GalleryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.site.id != oldWidget.site.id) {
      // print('didUpdateWidget:::::: NAME: ${oldWidget.site.name} >>>>>>>> ${widget.site.name}');
      // print('didUpdateWidget:::::: DATA: ${widget.controller.items} <<<<<<<< ${oldWidget.controller.items}');
      // 销毁被旧的滚动控制器
      // oldWidget.controller.scrollController?.dispose();
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _initialize();
          // _models = widget.controller.models;
          // _preloadModels = [];
          // print('FINALMODELS: $_models');
          // _refreshController.requestRefresh();
        });
      });
      updateKeepAlive();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// 预加载列表
  // Future<void> _preload() async {
  //   if (_itemsPreloaded.isNotEmpty) return;
  //   final page = _page + 1;
  //   try {
  //     _itemsPreloaded = await _requestItems(page: page);
  //     // 为空则返回
  //     if (_itemsPreloaded.isEmpty) return;
  //     // 页码改变则返回
  //     if (page == _page + 1) {
  //       // print('CURRENT PAGE: $_page ===> PRELOAD PAGE: $page');
  //     } else {
  //       _itemsPreloaded = [];
  //       return;
  //     }
  //     for (var model in _itemsPreloaded) {
  //       ExtendedImage.network(model.coverUrl ?? '')
  //           .image
  //           .resolve(const ImageConfiguration());
  //       // DynamicCacheImageProvider(model.coverUrl ?? '').resolve(const ImageConfiguration());
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
