import 'dart:io';

import 'package:chat/models/messages_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  final _focusNd = FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;

  List<ChatMessage> _messages = [];
  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket
        .on('private-message', (data) => _messagesListener(data));

    _loadHistory(chatService.toUser.uid);
  }

  void _loadHistory(String userID) async {
    List<Message> chat = await chatService.getChat(userID);
    final history = chat.map((m) => ChatMessage(
        text: m.message,
        uid: m.from,
        animationCtrl: AnimationController(
            vsync: this, duration: Duration(milliseconds: 0))
          ..forward()));
    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _messagesListener(dynamic payload) {
    ChatMessage message = new ChatMessage(
        text: payload['message'],
        uid: payload['uid'],
        animationCtrl: AnimationController(
            vsync: this, duration: Duration(milliseconds: 300)));

    setState(() {
      _messages.insert(0, message);
    });

    message.animationCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final toUSer = chatService.toUser;
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                toUSer.name.substring(0, 2),
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              toUSer.name,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Row(
          children: [
            Flexible(
                child: TextField(
              controller: _textCtrl,
              onSubmitted: _handleSubmit,
              onChanged: (String text) {
                setState(() {
                  if (text.trim().length > 0) {
                    _isWriting = true;
                  } else {
                    _isWriting = false;
                  }
                });
              },
              decoration: InputDecoration.collapsed(hintText: 'Enviar mensaje'),
              focusNode: _focusNd,
            )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Enviar'),
                      onPressed: _isWriting
                          ? () => _handleSubmit(_textCtrl.text.trim())
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        color: Colors.blue[400],
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(
                          Icons.send,
                        ),
                        onPressed: _isWriting
                            ? () => _handleSubmit(_textCtrl.text.trim())
                            : null,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (text.length == 0) return;

    _textCtrl.clear();
    _focusNd.requestFocus();
    final newMessage = ChatMessage(
      uid: authService.user.uid,
      text: text,
      animationCtrl: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationCtrl.forward();
    setState(() {
      _isWriting = false;
    });

    socketService.emit('private-message', {
      'from': authService.user.uid,
      'to': chatService.toUser.uid,
      'message': text
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationCtrl.dispose();
    }
    socketService.socket.off('private-message');
    super.dispose();
  }
}
