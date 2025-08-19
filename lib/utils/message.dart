import 'dart:io';

class Message {
  static show({required String msg}) {
    if (Platform.isAndroid) {
      Message.show(msg: msg);
    }
  }
}