import 'package:comic_nyaa/models/typed_model.dart';
import 'package:comic_nyaa/state/gallery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryNotifier extends FamilyNotifier<GalleryState, int> {
  @override
  GalleryState build(int id) { 
    return GalleryState(clearSelection: () => {});
  }
  // lambda 风格 setter，直接操作 state
  void setKeywords(String value) => state = state.copyWith(keywords: value);
  void setItems(List<TypedModel> value) => state = state.copyWith(items: value);
  void setSelects(Map<int, TypedModel> value) =>
      state = state.copyWith(selects: value);
  void setScrollController(ScrollController? controller) =>
      state = state.copyWith(scrollController: controller);
  void setOnItemSelect(ValueChanged<Map<int, TypedModel>>? callback) =>
      state = state.copyWith(onItemSelect: callback);
  void setSearch(Future<void>? Function(String)? search) =>
      state = state.copyWith(search: search);
  void setRefresh(Future<void>? Function()? refresh) =>
      state = state.copyWith(refresh: refresh);
  void setClearSelection(void Function() callback) =>
      state = state.copyWith(clearSelection: callback);
}
