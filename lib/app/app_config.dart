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
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:comic_nyaa/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppConfig {
  AppConfig._();
  static const appName = 'ComicNyaa';
  static const uiFontFamily = null; //'sans-serif';

  static const downloadDirectoryName = 'ComicNyaa';
  static const rulesDirectoryName = 'rules';
  static Directory? _appDir;
  static Directory? _ruleDir;
  static Directory? _downloadDir;
  static Directory? _databaseDir;

  static FutureOr<Directory> get appDir async {
    _appDir ??= await getApplicationDocumentsDirectory();
    return _appDir!;
  }

  static FutureOr<Directory> get ruleDir async {
    _ruleDir ??= Directory((await appDir).join(rulesDirectoryName));
    await _ruleDir?.create(recursive: true);
    return _ruleDir!;
  }

  static FutureOr<Directory> get downloadDir async {

    _downloadDir ??= Directory((await _getDownloadPath()).join(downloadDirectoryName));
    await _downloadDir?.create(recursive: true);
    return _downloadDir!;
  }

  static FutureOr<Directory> get databaseDir async {
    _databaseDir ??= Directory(await getDatabasesPath());
    return _databaseDir!;
  }
}

FutureOr<Directory> _getDownloadPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await directory.exists()) directory = await getExternalStorageDirectory();
    } else if (Platform.isWindows) {
      directory = Directory(p.join("download"));
    } else {
      directory = Directory(p.join("download"));
    }
  } catch (err) {
    throw(FileSystemException("Cannot get download folder path: $err"));
  }
  return directory!;
}