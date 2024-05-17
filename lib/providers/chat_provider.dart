import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/firestore_constants.dart';
import '../models/message_chat.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseDatabase firebaseDatabase;
  final FirebaseStorage firebaseStorage;

  ChatProvider({required this.firebaseDatabase, required this.prefs, required this.firebaseStorage});
  String? pushToken = '';
  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseDatabase.ref().child(collectionPath).child(docPath).update(dataNeedUpdate);
  }
  Stream<DatabaseEvent> getChatStream(String groupChatId) {
    print(groupChatId);
    return FirebaseDatabase.instance
        .ref()
        .child('messages')
        .child(groupChatId)
        .orderByChild('timestamp').onValue;
  }

  Future<void> sendMessage(String content, String groupChatId, String currentUserId, String peerId) async {
    try {
      final DatabaseReference messagesRef = FirebaseDatabase.instance.ref().child('messages');
      final DatabaseReference userRef = FirebaseDatabase.instance.ref()
          .child('users').child(currentUserId);
      DataSnapshot tokenSnap = await userRef.get();

      if (tokenSnap.exists) {
        pushToken = tokenSnap.child('pushToken').value as String?;
        if (pushToken != null) {
          print('Push Token: $pushToken');
        } else {
          print('Push Token not found');
        }
      } else {
        print('User data not found');
      }
          final DatabaseReference peerRef = FirebaseDatabase.instance.ref()
          .child('users').child(peerId);
      final DatabaseReference groupMessagesRef = messagesRef.
      child(groupChatId);

      DataSnapshot snapshot = await userRef.child('isChatedWith').get();
      DataSnapshot peerSnapshot = await peerRef.child('isChatedWith').get();
      print('${snapshot.value}');
      List<dynamic> isChatedList = snapshot.value != null ? List<dynamic>.from(snapshot.value as List) : [];
      List<dynamic> isChatedList2 = peerSnapshot.value != null ?
      List<dynamic>.from(peerSnapshot.value as List) : [];

      bool peerAlreadyChated = isChatedList.contains(peerId);
      bool peerAlreadyChated2 = isChatedList2.contains(currentUserId);

      if (!peerAlreadyChated && !peerAlreadyChated2) {
        isChatedList.add(peerId);
        isChatedList2.add(currentUserId);
        await userRef.child('isChatedWith').set(isChatedList);
        await peerRef.child('isChatedWith').set(isChatedList2);
      }
      final messageData = {
        'idFrom': currentUserId,
        'idTo': peerId,
        'timestamp': DateTime.now().microsecondsSinceEpoch.toString(),
        'content': content,
      };
      await groupMessagesRef.push().set(messageData);

      print('Message sent successfully');
    } catch (e, t) {
      print('error: $e');
      print('trace: $t');
    }
  }






}

