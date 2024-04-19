import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:chat/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
      () {
        setState(() {
          _isAnimate = true;
        });
      },
    );
  }

  void handleGoogleBtnClick() async {
    Dialogs.showProgressbar(context);
    try {
      final userCredential = await _signInWithGoogle();
      final user = userCredential.user;
      if (user != null) {
        final userExist = await API.userExist();
        if (!userExist) {
          try {
            await API.getCurrentUser();
          } catch (error) {
            log('Create User error: $error');
            return;
          }
        }
        await API.getCurrentUser();
        final currentUser = API.currentUser;
        if (currentUser != null && mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (error) {
      log('SignInWithGoogle failed: $error');
      if (mounted) {
        Navigator.pop(context);
        Dialogs.showSnackbar(
          context,
          const SnackContentError(
              errorMessage: 'Something Went Wrong (Check Internet!)'),
        );
      }
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await API.auth.signInWithCredential(credential);
    } catch (error) {
      log('\n_signInWithGoogle: $error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Welcome to We Chat',
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            width: mq.width * .5,
            left: _isAnimate ? mq.width * .25 : mq.width,
            duration: const Duration(
              milliseconds: 300,
            ),
            child: Image.asset(
              'images/icon.png',
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width * .9,
            left: mq.width * .05,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              onPressed: handleGoogleBtnClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent.shade100,
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              icon: Image.asset(
                'images/google.png',
                height: mq.height * .03,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(text: 'Signin with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
