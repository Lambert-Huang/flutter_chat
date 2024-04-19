import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  bool get _isUpdateButtonEnabled => _formKey.currentState?.validate() ?? false;

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
        padding: EdgeInsets.only(
          top: mq.height * .03,
          bottom: mq.height * .05,
        ),
        children: [
          const Text(
            'Pick Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: mq.height * .02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * .3, mq.height * .15),
                ),
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (image != null) {
                    await API.updateProfilePic(
                      File(image.path),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Image.asset(
                  'images/add_image.png',
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width * .3, mq.height * .15),
                ),
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (image != null) {
                    await API.updateProfilePic(
                      File(image.path),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Image.asset(
                  'images/camera.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: _showBottomSheet,
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) => API.currentUser?.name = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name Required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Michael',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (value) => API.currentUser?.about = value ?? '',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.info,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Bio',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        try {
                          await API.updateUserInfo();
                          if (context.mounted) {
                            Dialogs.showSnackbar(
                                context,
                                const SnackContentMessage(
                                    message: 'Profile Updated Successfully!'));
                            Navigator.pop(context);
                          }
                        } catch (error) {}
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .06),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: 28,
                    ),
                    label: const Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressbar(context);
              signOutCallback() {
                if (context.mounted) {
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              }

              try {
                await API.auth.signOut();
                await GoogleSignIn().signOut();
                signOutCallback();
              } catch (_) {
                signOutCallback();
              }
            },
            icon: const Icon(
              Icons.exit_to_app,
            ),
            label: const Text('Logout'),
          ),
        ),
      ),
    );
  }
}
