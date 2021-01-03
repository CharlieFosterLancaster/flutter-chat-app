import 'dart:io';

import 'package:chat/widgets/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  final _focusNd = FocusNode();
  List<Message> _messages = [
    // Message(
    //   text: 'Hola mundo',
    //   uid: '123',
    // ),
    // Message(
    //   text: 'Hola mundo',
    //   uid: '1',
    // ),
    // Message(
    //   text: 'Hola mundo',
    //   uid: '123',
    // ),
    // Message(
    //   text: 'Hola mundo',
    //   uid: '1',
    // ),
    // Message(
    //   text: 'Hola mundo',
    //   uid: '123',
    // ),
  ];
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                'Te',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              'Melissa Flores',
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
    final newMessage = Message(
      uid: '123',
      text: text,
      animationCtrl: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationCtrl.forward();
    setState(() {
      _isWriting = false;
    });
  }

  @override
  void dispose() {
    for (Message message in _messages) {
      message.animationCtrl.dispose();
    }
    super.dispose();
  }
}
