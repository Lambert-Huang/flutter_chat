import 'dart:developer';

import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/auth/Profile_Screen.dart';
import 'package:chat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _users = [];
  List<ChatUser> _searchUsers = [];
  bool _isSearching = false;
  List<ChatUser> get _displayUsers => _isSearching ? _searchUsers : _users;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: !_isSearching,
        onPopInvoked: (pop) {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, etc...',
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: .5,
                    ),
                    onChanged: (value) {
                      _searchUsers.clear();
                      for (var user in _users) {
                        if (user.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            user.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchUsers.add(user);
                        }
                      }
                      setState(() {
                        _searchUsers;
                      });
                    },
                  )
                : const Text(
                    'We Chat',
                  ),
            leading: const Icon(
              CupertinoIcons.home,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchUsers = [];
                    }
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  final currentUser = API.currentUser;
                  if (currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          user: currentUser,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              onPressed: () async {},
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.add_comment_rounded,
                color: Colors.black,
              ),
            ),
          ),
          body: StreamBuilder(
            stream: API.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                case ConnectionState.active:
                case ConnectionState.done:
                  _users = snapshot.data?.docs
                          .map(
                            (e) => ChatUser.fromJson(
                              e.data(),
                            ),
                          )
                          .toList() ??
                      [];
                  if (_displayUsers.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * .02),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _displayUsers.length,
                      itemBuilder: (context, index) => ChatUserCard(
                        user: _displayUsers[index],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No Users yet!',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
