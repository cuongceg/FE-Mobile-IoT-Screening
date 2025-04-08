import 'dart:convert';
import 'package:speech_to_text_iot_screen/network/api_urls.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class WebSocketServices {
  late WebSocketChannel _channel;
  WebSocketServices({
    String? userId,
    String? title,
    String description = '',
    List<String> isPublicTo = const [],
  }) {
    if(userId != null && title != null){
      _connect();
      _sendInitLecture(
        userId: userId,
        title: title,
        description: description,
        isPublicTo: isPublicTo,
      );
    }
  }

  void _connect() {
    _channel = IOWebSocketChannel.connect(webSocketURL);
  }

  void sendBufferIfNotEmpty({required StringBuffer buffer,required bool isEnd}) {
    final content = buffer.toString().trim();
    if(content.isNotEmpty){
      final delta = [
        {"insert":  isEnd ? "$content\n" : "$content "}
      ];

      final message = {
        "type":"content",
        "content": jsonEncode(delta),
      };

      _channel.sink.add(jsonEncode(message));
    }
  }

  void _sendInitLecture({
    required String userId,
    required String title,
    String description = '',
    List<String> isPublicTo = const [],
  }) {
    final initMessage = {
      "type": "init",
      "userId": userId,
      "meta": {
        "title": title,
        "description": description,
        "isPublicTo": isPublicTo
      }
    };

    _channel.sink.add(jsonEncode(initMessage));
  }


  void close() {
    _channel.sink.close();
  }
}