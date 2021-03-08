import 'package:chat/global/enviroment.dart';
import 'package:chat/models/messages_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/user.dart';

class ChatService with ChangeNotifier {
  User toUser;

  Future<List<Message>> getChat(String userID) async {
    final resp = await http.get('${Enviroment.apiUrl}/messages/$userID',
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken()
        });

    final messagesResponse = messagesResponseFromJson(resp.body);

    return messagesResponse.messages;
  }
}
