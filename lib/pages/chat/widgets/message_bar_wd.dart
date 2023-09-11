// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MessageBarWd extends StatelessWidget {
  final bool replying;
  final String replyingTo;
  final List<Widget> actions;
  final TextEditingController controller;
  final Color replyWidgetColor;
  final Color replyIconColor;
  final Color replyCloseColor;
  final Color messageBarColor;
  final Color sendButtonColor;
  final void Function(String)? onTextChanged;
  final Function(String) onSend;
  final void Function()? onTapCloseReply;

  const MessageBarWd(
      {required this.controller,
      this.replying = false,
      this.replyingTo = "",
      this.actions = const [],
      this.replyWidgetColor = const Color(0xffF4F4F5),
      this.replyIconColor = Colors.blue,
      this.replyCloseColor = Colors.black12,
      this.messageBarColor = const Color(0xffF4F4F5),
      this.sendButtonColor = Colors.blue,
      this.onTextChanged,
      required this.onSend,
      this.onTapCloseReply,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: messageBarColor,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: Row(
              children: <Widget>[
                ...actions,
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                    onChanged: onTextChanged,
                    decoration: InputDecoration(
                      hintText: "Rédigez votre message",
                      hintMaxLines: 1,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 0.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.black26,
                          width: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: InkWell(
                    child: Icon(
                      Icons.send,
                      color: sendButtonColor,
                      size: 24,
                    ),
                    onTap: () {
                      onSend(controller.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
