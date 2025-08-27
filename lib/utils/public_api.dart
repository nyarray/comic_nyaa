import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../library/http/http.dart';

final Logger logger = Logger();

class Hitokoto {
  final String hitokoto;
  final String type;
  final String from;

  const Hitokoto({
    this.hitokoto = '',
    this.type = '',
    this.from = '',
  });

  factory Hitokoto.fromJson(Map<String, dynamic> json) {
    return Hitokoto(
      hitokoto: json['hitokoto'] ?? '',
      type: json['type'] ?? '',
      from: json['from'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'hitokoto': hitokoto,
        'type': type,
        'from': from,
      };
}

final randomImageProvider =
    FutureProvider.family<String?, int>((ref, seed) async {
  try {
    final response = await Http.client.post(Uri.parse('https://pic.re/image'));
    // final response = await Http.client.get(
        // Uri.parse('https://random-picture.vercel.app/api/?json&seed=$seed'));
    final json = Map<String, dynamic>.from(jsonDecode(response.body));
    final url = Uri.parse('https://${json['file_url']}').toString();
    return url;
  } catch (e) {
    logger.w(e);
    return null;
  }
});

final randomHitokotoProvider =
    FutureProvider.family<Hitokoto?, int>((ref, seed) async {
  try {
    final response = await Http.client
        .get(Uri.parse('https://v1.hitokoto.cn/?c=a&c=b&seed=$seed'));
    return Hitokoto.fromJson(jsonDecode(response.body));
  } catch (e) {
    logger.w(e);
    return null;
  }
});
