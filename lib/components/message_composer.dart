import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageComposer extends StatefulWidget {
  final Function onSendPressed;

  MessageComposer({this.onSendPressed});

  @override
  _MessageComposerState createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final messageTextController = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kMessageContainerDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: messageTextController,
              decoration: kMessageTextFieldDecoration,
              onChanged: (value) {
                setState(() {
                  _isComposing = value.length > 0;
                });
              },
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.send,
                color: _isComposing ? Colors.lightBlueAccent : null,
              ),
              onPressed: _isComposing
                  ? () async {
                      widget.onSendPressed(messageTextController.text);
                      messageTextController.clear();
                      setState(() {
                        _isComposing = false;
                      });
                    }
                  : null),
        ],
      ),
    );
  }
}
