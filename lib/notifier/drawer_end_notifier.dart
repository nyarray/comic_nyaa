import 'package:comic_nyaa/state/drawer_end_state.dart';
import 'package:comic_nyaa/utils/public_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerEndNotifier extends Notifier<DrawerEndState> {
  @override
  DrawerEndState build() {
    _init();
    return const DrawerEndState();
  }
  
  void _init() async {
    final banner = await ref.watch(randomImageProvider(2).future) ?? '';
    state = state.copyWith(banner: banner);

  }

  void setExpandState(Map<int, bool> expandState) {
    state = state.copyWith(expandState: expandState);
  }

  void setScrollPosition(double scrollPosition) {
    state = state.copyWith(scrollPosition: scrollPosition);
  }

  void setBanner(String banner) {
    state = state.copyWith(banner: banner);
  }
}
