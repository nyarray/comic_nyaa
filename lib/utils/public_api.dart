import 'dart:convert';

import 'package:logger/logger.dart';

import '../library/http/http.dart';

final Logger logger = Logger();

class Hitokoto {
  String hitokoto = '';
  String type = '';
  String from = '';

  Hitokoto.fromJson(Map<String, dynamic> json) {
    hitokoto = json['hitokoto'];
    type = json['type'];
    from = json['from'];
  }

  Hitokoto();
}

Future<String> apiRandomImage() async {
  try {
    
  final response = await Http.client
      .get(Uri.parse('https://random-picture.vercel.app/api/?json'));
  final json = Map<String, dynamic>.from(jsonDecode(response.body));
  final url = json['url'].toString();
  return url;
  } catch (e) {
    logger.w(e);
  }
  return '';
}

Future<Hitokoto> apiHitokoto() async {
  final response =
      await Http.client.get(Uri.parse('https://v1.hitokoto.cn/?c=a&c=b'));
  return Hitokoto.fromJson(jsonDecode(response.body));
}
