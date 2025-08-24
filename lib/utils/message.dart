import 'dart:io';

import 'package:comic_nyaa/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Message {
  static show({required String msg}) {
    if (Platform.isAndroid) {
      // Message.show(msg: msg);
      Fluttertoast.showToast(msg: msg);
    } else {
      BuildContext? context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
