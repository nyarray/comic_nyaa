import 'package:comic_nyaa/models/typed_model.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_state.freezed.dart';

@freezed
abstract class GalleryState with _$GalleryState {
  factory GalleryState({
    @Default('') String keywords,
    @Default([]) List<TypedModel> items,
    @Default({}) Map<int, TypedModel> selects,
    ScrollController? scrollController,
    ValueChanged<Map<int, TypedModel>>? onItemSelect,
    Future<void>? Function(String keywords)? search,
    Future<void>? Function()? refresh,
    required void Function() clearSelection,
  }) = _GalleryState;
}
