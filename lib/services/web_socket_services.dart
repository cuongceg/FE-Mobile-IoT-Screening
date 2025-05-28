import 'dart:convert';
import 'package:speech_to_text_iot_screen/network/api_urls.dart';
import 'package:speech_to_text_iot_screen/services/auth_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class WebSocketServices {
  late WebSocketChannel _channel;
  WebSocketServices({
    String? title,
    String description = '',
    List<String> isPublicTo = const [],
  }) {
    if(title != null){
      _connect();
      _sendInitLecture(
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
    required String title,
    String description = '',
    List<String> isPublicTo = const [],
  }) async {
    try {
      String? userId = await AuthService().getUserID();
      if (userId == null) {
        throw Exception("User ID is required to initialize the lecture.");
      }
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
    } catch (e) {
      print("Error sending init lecture: $e");
    }
  }


  void close() {
    _channel.sink.close();
  }
}