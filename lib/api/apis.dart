import 'dart:convert';

import 'package:chat/models/chat_user.dart';
import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class API {
  static get auth => FirebaseAuth.instance;
  static FirebaseFirestore get fireStore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get fMessaging => FirebaseMessaging.instance;
  static String fcmSendURL = 'https://fcm.googleapis.com/fcm/send';
  // Bearer Token
  //
  // {
  //   'to': String,
  //   'notitication': {
  //     'title': 'Hello',
  //     'body': 'Hello Everyone'
  //   }
  // }
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    final fcmToken = await fMessaging.getToken();
    debugPrint('Push Token: $fcmToken');
    if (fcmToken != null) {
      currentUser?.pushToken = fcmToken;
    }
  }

  static Future<void> sendPushNotificationTo({
    required String userPushToken,
    required String msg,
  }) async {
    try {
      final bodyObject = {
        'to': userPushToken,
        'notification': {
          'title': 'From ${currentUser?.name}',
          'body': msg,
        },
      };
      final response = await post(
        Uri.parse(fcmSendURL),
        body: jsonEncode(bodyObject),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAYX7ez14:APA91bEoCmfKMsgAd3ueAigAHD1VJRPzg7vrCLrxpLrBOt3kcPYQCIrvc5wCXguq9xfYIZLvOaNaU7K3P6sz2IvnN8u8t4POrjLpRgbP7A_BqEMJeo992kcNmeTVhmEW0JrYIYR6bQIZ',
        },
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    } catch (e) {
      debugPrint('\nsendPusthNotificationError: $e');
    }
  }

  static User? get authUser => auth.currentUser;
  static ChatUser? currentUser;
  static Future<bool> userExist() async {
    return (await fireStore.collection('users').doc(authUser?.uid).get())
        .exists;
  }

  static Future<void> getCurrentUser() async {
    final currentUserData =
        (await fireStore.collection('users').doc(authUser?.uid).get()).data();
    if (currentUserData != null) {
      currentUser = ChatUser.fromJson(currentUserData);
    } else if (authUser != null) {
      currentUser = await createUser();
    }
    await getFirebaseMessagingToken();
  }

  static Future<ChatUser> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: authUser!.photoURL.toString(),
      about: "Hey, I'm using We Chat!",
      name: authUser!.displayName.toString(),
      createdAt: time,
      isOnline: true,
      id: authUser!.uid,
      lastActive: time,
      email: authUser!.email.toString(),
      pushToken: '',
    );
    await fireStore
        .collection('users')
        .doc(authUser?.uid)
        .set(chatUser.toJson());
    return chatUser;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return fireStore
        .collection('users')
        .where(
          'id',
          isNotEqualTo: authUser?.uid,
        )
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo({
    required String userId,
  }) {
    return fireStore
        .collection('users')
        .where(
          'id',
          isEqualTo: userId,
        )
        .limit(1)
        .snapshots();
  }

  static Future<void> updateActiveStatus({required bool isOnline}) async {
    return fireStore.collection('users').doc(currentUser?.id).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': currentUser?.pushToken,
    });
  }

  static Future<void> updateUserInfo() async {
    await fireStore.collection('users').doc(currentUser?.id).update(
      {
        'name': currentUser?.name ?? '',
        'about': currentUser?.about ?? '',
      },
    );
  }

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${currentUser?.id}.$ext');
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );
    uploadTask.snapshotEvents.listen(
      (snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            final progress =
                100.0 * snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint('UploadAvatar -->> progress: $progress');
            break;
          case TaskState.paused:
            debugPrint('UploadAvatar -->> paused');
            break;
          case TaskState.canceled:
            debugPrint('UploadAvatar -->> canceled');
            break;
          case TaskState.error:
            debugPrint('UploadAvatar -->> error');
            break;
          case TaskState.success:
            debugPrint('UploadAvatar -->> succeed');
            break;
        }
      },
      onError: (e) {
        debugPrint('UploadAvatar -->> failed: $e');
      },
    );
    try {
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('UploadAvatar -->> download Url: $downloadUrl');
      await fireStore.collection('users').doc(currentUser?.id).update(
        {
          'image': downloadUrl,
        },
      );
      currentUser?.image = downloadUrl;
    } catch (e) {
      debugPrint('UploadAvatar -->> failed: $e');
    }
  }

  static String? getConversationID(String id) {
    if (authUser == null) {
      return null;
    }
    final uidHashcode = authUser!.uid.hashCode;
    return uidHashcode <= id.hashCode
        ? '${authUser!.uid}_$id'
        : '${id}_${authUser!.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesOf(
      {required String user}) {
    final conversationId = getConversationID(user);
    if (conversationId == null) {
      return const Stream.empty();
    }
    return fireStore
        .collection('chats/$conversationId!/messages/')
        .orderBy('sentAt', descending: true)
        .snapshots();
  }

  static Future<void> sendMessageTo({
    required ChatUser user,
    required String msg,
    required MessageType type,
  }) async {
    final conversationId = getConversationID(user.id);
    if (conversationId == null) {
      return Future.value();
    }
    final sentAt = DateTime.now().millisecondsSinceEpoch.toString();
    final message = Message(
        toId: user.id,
        msg: msg,
        sentAt: sentAt,
        readAt: '',
        type: type,
        fromId: currentUser!.id);
    final ref = fireStore.collection('chats/$conversationId!/messages/');
    await ref.doc(sentAt).set(message.toJson());
    await sendPushNotificationTo(userPushToken: user.pushToken, msg: msg);
  }

  static Future<void> updateMessageReadStatus(Message msg) async {
    final conversationId = getConversationID(msg.fromId);
    if (conversationId == null) {
      return;
    }
    final readAt = DateTime.now().millisecondsSinceEpoch.toString();
    fireStore
        .collection('chats/$conversationId!/messages/')
        .doc(msg.sentAt)
        .update(
      {
        'readAt': readAt,
      },
    );
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    final conversationId = getConversationID(user.id);
    if (conversationId == null) {
      return const Stream.empty();
    }
    return fireStore
        .collection('chats/$conversationId!/messages/')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser user, File file) async {
    final conversationId = getConversationID(user.id);
    if (conversationId == null) {
      return Future.value();
    }
    final ext = file.path.split('.').last;
    final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = storage.ref().child('images/$conversationId!/$imageName.$ext');
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );
    uploadTask.snapshotEvents.listen(
      (snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            final progress =
                100.0 * snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint('UploadAvatar -->> progress: $progress');
            break;
          case TaskState.paused:
            debugPrint('UploadAvatar -->> paused');
            break;
          case TaskState.canceled:
            debugPrint('UploadAvatar -->> canceled');
            break;
          case TaskState.error:
            debugPrint('UploadAvatar -->> error');
            break;
          case TaskState.success:
            debugPrint('UploadAvatar -->> succeed');
            break;
        }
      },
      onError: (e) {
        debugPrint('UploadAvatar -->> failed: $e');
      },
    );
    try {
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('UploadAvatar -->> download Url: $downloadUrl');
      await sendMessageTo(
          user: user, msg: downloadUrl, type: MessageType.image);
    } catch (e) {
      debugPrint('UploadAvatar -->> failed: $e');
    }
  }
}
