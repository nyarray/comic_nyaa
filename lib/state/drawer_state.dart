
import 'package:comic_nyaa/utils/public_api.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drawer_state.freezed.dart';

@freezed
abstract class DrawerState with _$DrawerState {
  const factory DrawerState({
    @Default('') String banner,
    @Default(Hitokoto()) Hitokoto hitokoto,
  }) = _DrawerState;
}