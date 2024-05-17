// To parse this JSON data, do
//
//     final userChat = userChatFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import '../constants/firestore_constants.dart';

UserChat userChatFromJson(String str) => UserChat.fromJson(json.decode(str));

String userChatToJson(UserChat data) => json.encode(data.toJson());

class UserChat {
  final String? id;
  final String? photoUrl;
  final String? nickname;
  final String? aboutMe;

  UserChat({
    this.id,
    this.photoUrl,
    this.nickname,
    this.aboutMe,
  });

  factory UserChat.fromJson(Map<String, dynamic> json) => UserChat(
    id: json["id"],
    photoUrl: json["photoUrl"],
    nickname: json["nickname"],
    aboutMe: json["aboutMe"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "photoUrl": photoUrl,
    "nickname": nickname,
    "aboutMe": aboutMe,
  };
  factory UserChat.fromSnapshot(DataSnapshot snapshot) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
    return UserChat(
      id: snapshot.key ?? "",
      photoUrl: data["photoUrl"] ?? "",
      nickname: data["nickname"] ?? "",
      aboutMe: data["aboutMe"] ?? "",
    );
  }
  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (_) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (_) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (_) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }
}
