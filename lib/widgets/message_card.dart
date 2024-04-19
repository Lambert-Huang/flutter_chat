import 'package:chat/helper/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return API.currentUser?.id == widget.message.fromId
        ? _senderMessage()
        : _receiverMessage();
  }

  // green bubble
  Widget _senderMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 16),
          child: Row(
            children: [
              Text(
                DateUtil.getFormattedTimeString(
                    context: context, time: widget.message.sentAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              if (widget.message.readAt.isNotEmpty)
                const Icon(
                  Icons.done_all_rounded,
                  color: Colors.lightGreen,
                  size: 20,
                ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            constraints: BoxConstraints(
              maxWidth: mq.width * 0.8, // 气泡的最大宽度为屏幕宽度的80%
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightGreen),
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightGreen.withOpacity(0.6),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _receiverMessage() {
    if (widget.message.readAt.isEmpty) {
      API.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            constraints: BoxConstraints(
              maxWidth: mq.width * 0.8, // 气泡的最大宽度为屏幕宽度的80%
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              color: const Color.fromARGB(255, 221, 245, 255),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlue.withOpacity(.6),
                  offset: Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 16),
          child: Text(
            DateUtil.getFormattedTimeString(
                context: context, time: widget.message.sentAt),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
