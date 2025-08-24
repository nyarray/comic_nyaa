import 'dart:io';

import 'package:comic_nyaa/models/typed_model.dart';
import 'package:comic_nyaa/utils/uri_extensions.dart';

import '../app/app_preference.dart';

extension ScopeFunctions<T> on T {
  /// Kotlin also: 执行 block，但返回 this
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Kotlin let: 执行 block，并返回 block 的结果
  R let<R>(R Function(T it) block) {
    return block(this);
  }
}

extension ExtendedPath on FileSystemEntity {
  Directory joinDir(Directory child) {
    return Directory(join(child.path));
  }

  File joinFile(Directory child) {
    return File(join(child.path));
  }

  String join(String child) {
    return '$path${Platform.pathSeparator}$child';
  }
}

extension TypedModelExt on TypedModel {
  String getUrl(DownloadSourceQuality downloadResourceLevel) {
    String? url;
    switch (downloadResourceLevel) {
      case DownloadSourceQuality.low:
        url = sampleUrl ?? largerUrl ?? originUrl;
        break;
      case DownloadSourceQuality.medium:
        url = largerUrl ?? originUrl ?? sampleUrl;
        break;
      case DownloadSourceQuality.high:
        url = originUrl ?? largerUrl ?? sampleUrl;
        break;
    }
    return url ?? '';
  }

  String get availablePreviewUrl {
    String? url;
    if (children != null) {
      final first = children!.first;
      url = first.sampleUrl ?? first.largerUrl ?? first.originUrl;
    }
    url = url ?? sampleUrl ?? largerUrl ?? originUrl;

    return Uri.encodeFull(url ?? '').asUrl;
  }

  String get availableCoverUrl {
    String? url;
    if (children != null) {
      final first = children!.first;
      url = first.coverUrl ??
          first.sampleUrl ??
          first.largerUrl ??
          first.originUrl;
    }
    url = url ?? coverUrl ?? sampleUrl ?? largerUrl ?? originUrl;
    return url?.asUrl ?? '';
  }


  isSni() async {
    final df = getOrigin().site.domainFronting;
    final locale = (await AppPreferences.instance).locale;
    if (locale == df?.country) {
      return true;
    }
    return false;
  }
}
