import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/auth/view_profile_Screen.dart';
import 'package:chat/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  final _scrollController = ScrollController();

  Future<File?> _pickImageFrom({
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 70);
    return image == null ? null : File(image.path);
  }

  Future<List<File>> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 70);
    return images.map((e) => File(e.path)).toList();
  }

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
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewProfileScreen(user: widget.user),
        ),
      ),
      child: StreamBuilder(
        stream: API.getUserInfo(userId: widget.user.id),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs.first;
          var conversationUser = widget.user;
          final userInfo = data?.data();
          if (userInfo != null) {
            conversationUser = ChatUser.fromJson(userInfo);
          }
          return Row(
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
                  fit: BoxFit.fill,
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: conversationUser.image,
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
                    conversationUser.name,
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
                    conversationUser.isOnline
                        ? 'Online'
                        : DateUtil.getLastActiveTime(
                            context: context,
                            lastActive: conversationUser.lastActive),
                    style: TextStyle(
                      fontSize: 13,
                      color: conversationUser.isOnline
                          ? Colors.green
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
                    onPressed: () async {
                      final imageFiles = await _pickImagesFromGallery();
                      for (var file in imageFiles) {
                        setState(() => _isUploading = true);
                        await API.sendChatImage(widget.user, file);
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      size: 26,
                    ),
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    onPressed: () async {
                      final imageFile =
                          await _pickImageFrom(source: ImageSource.camera);
                      if (imageFile != null) {
                        setState(() => _isUploading = true);
                        await API.sendChatImage(widget.user, imageFile);
                        setState(() => _isUploading = false);
                      }
                    },
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
                  user: widget.user,
                  msg: _textController.text,
                  type: MessageType.text,
                );
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
              _messages.clear();
              _messages = updateMessages;
              if (_messages.isNotEmpty) {
                return ListView.builder(
                  reverse: true,
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
