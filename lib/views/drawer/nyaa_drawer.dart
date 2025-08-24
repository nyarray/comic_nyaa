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

import 'package:comic_nyaa/utils/extensions.dart';
import 'package:comic_nyaa/utils/public_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:get/get.dart';

import '../../utils/flutter_utils.dart';
import '../../widget/simple_network_image.dart';
import '../download_view.dart';
import '../settings_view.dart';
import '../subscribe_view.dart';

part 'nyaa_drawer.freezed.dart';

@freezed
abstract class NyaaDrawerState with _$NyaaDrawerState {
  const factory NyaaDrawerState({
    @Default('') String banner,
    @Default(Hitokoto()) Hitokoto hitokoto,
  }) = _NyaaDrawerState;
}

class NyaaDrawerNotifier extends Notifier<NyaaDrawerState> {
  @override
  NyaaDrawerState build() => const NyaaDrawerState();
  
  void setBanner(String url) => state = state.copyWith(banner: url);
  void setHitokoto(Hitokoto hitokoto) =>
      state = state.copyWith(hitokoto: hitokoto);
}

final drawerNotifierProvider =
    NotifierProvider<NyaaDrawerNotifier, NyaaDrawerState>(
        NyaaDrawerNotifier.new);

class NyaaDrawer extends ConsumerWidget {
  const NyaaDrawer({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final state = ref.watch(drawerNotifierProvider);
    final notifier = ref.read(drawerNotifierProvider.notifier);
    state.banner.isEmpty.also((_) => ref
        .watch(randomImageProvider(1))
        .whenData((data) => notifier.setBanner(data)));
    ref
        .watch(randomHitokotoProvider(1))
        .whenData((data) => notifier.setHitokoto(data));

    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
              elevation: 4,
              child: Stack(children: [
                _buildHeader(state),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.grey.withValues(alpha: 0.0),
                              Colors.black45,
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ])),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    child: Text(state.hitokoto.hitokoto,
                        style:
                            TextStyle(color: Colors.teal[100], fontSize: 16)),
                  ),
                )
              ]))),
      ListTile(
          title: const Text('主页'),
          selected: true,
          selectedTileColor: const Color.fromRGBO(0, 127, 127, .2),
          onTap: () {},
          iconColor: Colors.teal,
          leading: const Icon(Icons.home)),
      ListTile(
          title: const Text('订阅'),
          onTap: () => RouteUtil.push(context, const SubscribeView()),
          iconColor: Colors.black87,
          leading: const Icon(Icons.collections_bookmark)),
      ListTile(
          title: const Text('下载'),
          onTap: () => RouteUtil.push(context, const DownloadView()),
          iconColor: Colors.black87,
          leading: const Icon(Icons.download)),
      ListTile(
          title: const Text('设置'),
          onTap: () => RouteUtil.push(context, const SettingsView()),
          iconColor: Colors.black87,
          leading: const Icon(Icons.tune))
    ]));
  }

  Widget _buildHeader(NyaaDrawerState state) {
    return Material(
        elevation: 4,
        child: state.banner.isNotEmpty
            ? SimpleNetworkImage(
                state.banner,
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: 160 + kToolbarHeight,
                animationDuration: Duration.zero,
              )
            : Container(height: 160 + kToolbarHeight));
  }
}
