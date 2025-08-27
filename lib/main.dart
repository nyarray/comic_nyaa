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
import 'dart:io' show HttpOverrides, Platform;
import 'dart:ui';
import 'package:comic_nyaa/app/app_preference.dart';
import 'package:comic_nyaa/data/download/nyaa_download_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_proxy/http_proxy.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app/app_config.dart';
import 'library/http/http.dart';
import 'library/mio/core/mio.dart';
import 'views/main_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // 隐藏状态栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  // 透明状态栏
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // 初始化数据库
  initializeDatabase();
  // 白屏优化
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ProviderScope(child: ComicNyaa()));
  FlutterNativeSplash.remove();
}

void initializeDatabase() {
  // Web 环境
  if (Platform.isWindows || Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
  }
}

/// Windows scrolling compatibility
class NyaaScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class ComicNyaa extends StatefulWidget {
  const ComicNyaa({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicNyaaState();
}

class _ComicNyaaState extends State<ComicNyaa> {
  void location(Locale? deviceLocale, Iterable<Locale> supportedLocales) async {
    (await AppPreferences.instance)
        .setLocale(deviceLocale?.languageCode ?? 'zh-TW');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: NyaaScrollBehavior(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: ThemeData(
        // fontFamily: 'ComicNeue',
        primarySwatch: Colors.teal,
      ),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        location(deviceLocale, supportedLocales);
        return supportedLocales.first;
      },
      home: const MainView(enableBackControl: true),
    );
  }

  @override
  void initState() {
    _initialized();
    super.initState();
  }

  void _initialized() {
    if (!Platform.isAndroid) {
      // 初始化显示模式
      setOptimalDisplayMode();
    }

    // 初始化Mio
    Mio.setCustomRequest((url, {Map<String, String>? headers}) async {
      if (Platform.isAndroid) {
        WidgetsFlutterBinding.ensureInitialized();
        HttpProxy httpProxy = await HttpProxy.createHttpProxy();
        HttpOverrides.global = httpProxy;
      }
      // 发送请求 Http Client
      headers ??= <String, String>{};
      // 域前置解析
      // url = await sni.parse(url, headers: headers);
      // print('REQUEST::: $url');
      // print('HEADERS::: $headers');
      final response = await Http.client.get(Uri.parse(url), headers: headers);
      final body = response.body;
      return body;
    });
    // 初始化下载管理
    NyaaDownloadManager.instance;
  }

  Future<void> setOptimalDisplayMode() async {
    try {
      final List<DisplayMode> supported = await FlutterDisplayMode.supported;
      final DisplayMode active = await FlutterDisplayMode.active;
      final List<DisplayMode> sameResolution = supported
          .where((DisplayMode m) =>
              m.width == active.width && m.height == active.height)
          .toList()
        ..sort((DisplayMode a, DisplayMode b) =>
            b.refreshRate.compareTo(a.refreshRate));

      final DisplayMode mostOptimalMode =
          sameResolution.isNotEmpty ? sameResolution.first : active;

      /// This setting is per session.
      /// Please ensure this was placed with `initState` of your root widget.
      await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
    } catch (e) {}
  }
}
