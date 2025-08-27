import 'package:freezed_annotation/freezed_annotation.dart';

part 'drawer_end_state.freezed.dart';

@freezed
abstract class DrawerEndState with _$DrawerEndState {
  const factory DrawerEndState({
    @Default({0: true}) Map<int, bool> expandState,
    @Default(0.0) double scrollPosition,
    @Default('') String banner,
  }) = _DrawerEndState;
}