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

import 'package:comic_nyaa/notifier/gallery_notifier.dart';
import 'package:comic_nyaa/state/gallery_state.dart';
import 'package:comic_nyaa/utils/message.dart';
import 'package:comic_nyaa/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:comic_nyaa/library/mio/model/site.dart';
import 'package:comic_nyaa/library/mio/core/mio.dart';
import 'package:comic_nyaa/models/typed_model.dart';
import 'package:comic_nyaa/widget/ink_stack.dart';
import 'package:comic_nyaa/widget/triangle_painter.dart';
import 'package:comic_nyaa/views/detail/image_detail_view.dart';
import 'package:comic_nyaa/views/detail/comic_detail_view.dart';
import 'package:comic_nyaa/views/detail/video_detail_view.dart';
import 'package:comic_nyaa/utils/flutter_utils.dart';

final galleryProvider =
    NotifierProvider.family<GalleryNotifier, GalleryState, int>(
        GalleryNotifier.new);

class GalleryView extends ConsumerStatefulWidget {
  const GalleryView(
      {Key? key,
      required this.site,
      required this.heroKey,
      this.color,
      this.scrollbarColor,
      this.empty})
      : super(key: key);
  final Site site;
  final String heroKey;
  final Color? color;
  final Color? scrollbarColor;
  final Widget? empty;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GalleryViewState();
  }
}

class GalleryViewState extends ConsumerState<GalleryView>
    with AutomaticKeepAliveClientMixin<GalleryView>, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final Map<int, ValueNotifier<double>> _itemsRatioNotifier = {};
  final List<TypedModel> _itemsPreloaded = [];
  int _page = 0;
  String _query = '';
  bool _isLoading = false;

  FamilyNotifierProvider<GalleryNotifier, GalleryState, int> get provider =>
      galleryProvider(widget.site.id);

  GalleryState get state => ref.watch(provider);
  GalleryNotifier get notifier => ref.read(provider.notifier);

  Future<void> _initialize() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

      notifier.setClearSelection(_clearSelections);
      notifier.setScrollController(_scrollController);
      notifier.setRefresh(_refreshController.requestRefresh);
      notifier.setSearch((String query) async {
        _query = query;
        await _refreshController.requestRefresh();
      });
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
    ref.read(provider.notifier).setSelects({});
    ref.watch(provider).onItemSelect?.call({});
  }

  /// 获取数据
  Future<List<TypedModel>> _fetchItems(
      {Site? site, int? page, String? keywords}) async {
    site ??= _currentSite;
    page ??= _page;
    keywords ??= _query;
    final results = await (Mio(site)
          ..setPage(page)
          ..setKeywords(keywords))
        .parseSite();
    return results.map(TypedModel.fromJson).toList();
  }

  void _reset() {
    setState(() {
      _page = 0;
      _query = '';
      _itemsRatioNotifier.clear();
      _itemsPreloaded.clear();
      _clearSelections();
      ref.read(provider.notifier).setItems([]);
    });
  }

  Future<void> _onNext() async {
    if (_isLoading) return;
    _page++;
    try {
      _isLoading = true;
      final results = await _fetchItems();
      if (results.isEmpty) {
        Message.show(msg: '已经到底了');
        return;
      }
      // 更新status
      final copy = List<TypedModel>.from(state.items);
      copy.addAll(results);
      ref.read(provider.notifier).setItems(copy);
    } catch (e) {
      Message.show(msg: e.toString());
      // rethrow;
    } finally {
      _refreshController.refreshCompleted();
      _isLoading = false;
    }
  }

  Future<void> _onSearch(String query) async {
    _reset();

    // ref.read(provider.notifier).setKeywords(_keywords);
    _query = query;
    _onNext();
  }

  _onRefresh() async {
    await _onSearch(_query);
  }

  void _jump(int index, String? heroKey) {
    final model = state.items[index];
    Widget? target;
    switch (model.$type) {
      case 'image':
        target = ImageDetailView(
            models: state.items, heroKey: widget.heroKey, index: index);
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
    final item = state.items[index];
    final copy = Map<int, TypedModel>.from(state.selects);
    if (copy.containsKey(index)) {
      copy.remove(index);
    } else {
      copy[index] = item;
    }
    notifier.setSelects(copy);
    if (state.onItemSelect != null) {
      state.onItemSelect!(copy);
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

    // super.build(context);
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
            child: state.items
                    .isNotEmpty /*||
                    _refreshController.isLoading ||
                    _refreshController.isRefresh*/
                ? MasonryGridView.count(
                    // padding: EdgeInsets.fromLTRB(8, _topOffset + 8, 8, 0),
                    padding: const EdgeInsets.all(8.0),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    itemCount: state.items.length,
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
    final coverUrl = state.items[index].availableCoverUrl;
    final heroKey = '${widget.heroKey}-$coverUrl-$index';
    // 初始化默认宽高比
    _itemsRatioNotifier.putIfAbsent(index, () => ValueNotifier<double>(1.33));
    return RepaintBoundary(
        child: Material(
      clipBehavior: Clip.hardEdge,
      shadowColor: Colors.black45,
      elevation: 2,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: InkStack(
        alignment: Alignment.center,
        splashColor: widget.color,
        onTap: () => state.selects.isEmpty
            ? _jump(index, heroKey)
            : _onItemSelect(index),
        onLongPress: () =>
            state.selects.isEmpty ? _onItemSelect(index) : _clearSelections(),
        children: [
          Column(children: [
            Hero(
              tag: heroKey,
              child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: ValueListenableBuilder<double>(
                      valueListenable: _itemsRatioNotifier[index]!,
                      builder: (_, ratio, __) {
                        return AspectRatio(
                            aspectRatio: ratio,
                            child: ExtendedImage.network(
                              coverUrl,
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
                                    return const Center(
                                        child:
                                            SpinKitPulse(color: Colors.grey));
                                  case LoadState.failed:
                                    return const AspectRatio(
                                        aspectRatio: 0.60,
                                        child: Icon(Icons.image_not_supported,
                                            size: 48));
                                  case LoadState.completed:
                                    final image =
                                        state.extendedImageInfo?.image;
                                    if (image != null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _itemsRatioNotifier[index]?.value =
                                            image.width / image.height;
                                      });
                                    }
                                    controller.forward();
                                    return null;
                                }
                              },
                              // afterPaintImage: (canvas, rect, image, paint) {}
                            ));
                      })),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                state.items[index].title ?? '',
                maxLines: 3,
              ),
            ),
          ]),
          state.selects.containsKey(index)
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
      _initialize();
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (state.items.isEmpty && !_isLoading) {
      //     _reset();
      //     _refreshController.requestRefresh();
      //   }
      // });
      print(
          'didUpdateWidget:::::: NAME: ${oldWidget.site.name} >>>>>>>> ${widget.site.name}');
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
