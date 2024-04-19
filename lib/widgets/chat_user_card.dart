import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/helper/date_util.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import '../api/apis.dart';
import '../main.dart';
import 'dart:developer';

import '../models/message.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({
    super.key,
    required this.user,
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _lastMessage;
  @override
  void initState() {
    super.initState();
    log('Avatar: ${widget.user.image}');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      elevation: .5,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                user: widget.user,
              ),
            ),
          );
        },
        child: StreamBuilder(
          stream: API.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            if (data != null && data.first.exists) {
              _lastMessage = Message.fromJson(data.first.data());
            }
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .055,
                  height: mq.height * .055,
                  imageUrl: widget.user.image,
                  // placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
              title: Text(
                widget.user.name,
              ),
              subtitle: Text(
                _lastMessage?.msg ?? '',
                maxLines: 1,
              ),
              trailing: _trailingWidget(),
            );
          },
        ),
      ),
    );
  }

  Widget? _trailingWidget() {
    if (_lastMessage == null) {
      return null;
    }
    return _lastMessage!.readAt.isEmpty
        ? Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          )
        : Text(
            DateUtil.getLastMessageTime(
              context: context,
              time: _lastMessage!.sentAt,
            ),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          );
  }
}
