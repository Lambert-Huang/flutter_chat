import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/helper/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .4,
              vertical: mq.height * .015,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade400,
            ),
          ),
          _OptionItem(
            icon: const Icon(
              Icons.copy_all_rounded,
              color: Colors.blue,
              size: 26,
            ),
            name: 'Copy',
            onTap: () {},
          ),
          _OptionItem(
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
              size: 26,
            ),
            name: 'Edit Message',
            onTap: () {},
          ),
          _OptionItem(
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 26,
            ),
            name: 'Delete Message',
            onTap: () {},
          ),
          _OptionItem(
            icon: const Icon(
              Icons.remove_red_eye,
              color: Colors.blue,
              size: 26,
            ),
            name: 'Sent At',
            onTap: () {},
          ),
          _OptionItem(
            icon: const Icon(
              Icons.remove_red_eye,
              color: Colors.red,
              size: 26,
            ),
            name: 'Read At',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSender = API.currentUser?.id == widget.message.fromId;
    return InkWell(
      onLongPress: _showBottomSheet,
      child: isSender ? _senderMessage() : _receiverMessage(),
    );
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
            padding: EdgeInsets.all(widget.message.type == MessageType.text
                ? mq.width * .04
                : mq.width * .03),
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
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
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
            padding: EdgeInsets.all(widget.message.type == MessageType.text
                ? mq.width * .04
                : mq.width * .03),
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
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
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

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .025,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(
              width: 8,
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
