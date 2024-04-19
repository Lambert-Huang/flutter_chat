import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          canPop: !_showEmoji,
          onPopInvoked: (pop) {
            if (_showEmoji) {
              setState(
                () => _showEmoji = false,
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 221, 245, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                _messageList(),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: 256,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          backgroundColor:
                              const Color.fromARGB(255, 221, 245, 255),
                          columns: 8,
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.3
                                  : 1.0),
                        ),
                        swapCategoryAndBottomBar: false,
                        skinToneConfig: const SkinToneConfig(),
                        categoryViewConfig: const CategoryViewConfig(),
                        bottomActionBarConfig: const BottomActionBarConfig(),
                        searchViewConfig: const SearchViewConfig(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: widget.user.image,
              // placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(CupertinoIcons.person),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                widget.user.about,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .025, vertical: mq.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      size: 26,
                    ),
                    color: Colors.blueAccent,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      onTap: () {
                        if (_showEmoji) setState(() => _showEmoji = false);
                      },
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Input here...',
                        hintStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      size: 26,
                    ),
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      size: 26,
                    ),
                    color: Colors.blueAccent,
                  ),
                  SizedBox(
                    width: mq.width * .02,
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            shape: const CircleBorder(),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 10,
              right: 5,
            ),
            onPressed: () async {
              if (_textController.text.isNotEmpty) {
                await API.sendMessageTo(
                    user: widget.user.id, msg: _textController.text);
                _textController.text = '';
              }
            },
            color: Colors.green,
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList() {
    return Expanded(
      child: StreamBuilder(
        stream: API.getAllMessagesOf(user: widget.user.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const SizedBox();
            case ConnectionState.active:
            case ConnectionState.done:
              final updateMessages = (snapshot.data?.docs ?? [])
                  .map((e) => Message.fromJson(e.data()))
                  .toList();
              if (updateMessages.length > _messages.length) {
                _messages = updateMessages;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                  );
                });
              }
              if (_messages.isNotEmpty) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: mq.height * .02),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => MessageCard(
                    message: _messages[index],
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'Say Hi! 👋',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
