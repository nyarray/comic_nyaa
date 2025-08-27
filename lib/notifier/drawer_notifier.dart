import 'package:comic_nyaa/state/drawer_state.dart';
import 'package:comic_nyaa/utils/public_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerNotifier extends Notifier<DrawerState> {
  @override
  DrawerState build() {
    _init();
    return const DrawerState();
  }

  void _init() async {
    final banner = await ref.watch(randomImageProvider(1).future) ?? '';
    final hitokoto = await ref.watch(randomHitokotoProvider(1).future) ?? const Hitokoto();
    state = state.copyWith(banner: banner, hitokoto: hitokoto);
  }

  void setBanner(String url) => state = state.copyWith(banner: url);
  void setHitokoto(Hitokoto hitokoto) =>
      state = state.copyWith(hitokoto: hitokoto);
}
