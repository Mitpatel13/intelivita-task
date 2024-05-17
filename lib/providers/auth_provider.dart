import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intelivita_task/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/firestore_constants.dart';
import '../models/user_chat.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProviders extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseDatabase firebaseDatabase;
  final SharedPreferences prefs;

  AuthProviders({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseDatabase,
  });

  Status _status = Status.uninitialized;

  Status get status => _status;

  String? get userFirebaseId => prefs.getString(FirestoreConstants.id);

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();
    print(googleSignInAccount);
    if (googleSignInAccount == null) {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

    User? firebaseUser = (await firebaseAuth.signInWithCredential(authCredential)).user;
    if (firebaseUser == null) {
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }

    final  userRef = firebaseDatabase
        .ref()
        .child(FirestoreConstants.pathUserCollection)
        .child(firebaseUser.uid);
    print("userres first ${userRef.ref}");

    final DataSnapshot snapshot = await userRef.ref.get();
    print('snapshot${snapshot.value}');
    if (!snapshot.exists) {
      // Writing data to server because here is a new user
      await userRef.set({
        FirestoreConstants.nickname: firebaseUser.displayName,
        FirestoreConstants.photoUrl: firebaseUser.photoURL,
        FirestoreConstants.id: firebaseUser.uid,
        FirestoreConstants.createdAt: DateTime.now().microsecondsSinceEpoch,
        FirestoreConstants.chattingWith: null
      });

      // Write data to local storage
      User? currentUser = firebaseUser;
      await prefs.setString(FirestoreConstants.id, currentUser.uid);
      await prefs.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
      await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
    } else {

      // Already sign up, just get data from firestore
      final userSnapshot = await userRef.ref.once();
      final userData = userSnapshot.snapshot.value;
      print('userdata is ${userData}');
      final userChat = UserChat.fromSnapshot(userSnapshot.snapshot);

      // final userChat = UserChat.fromJson(userRef.ref as Map<String, dynamic> );
      print("userchat second to save in local ${userChat.toJson()}");

      // Write data to local
      await prefs.setString(FirestoreConstants.id, userChat.id.toString());
      await prefs.setString(FirestoreConstants.nickname, userChat.nickname.toString());
      await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl.toString());
      await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe.toString());
    }
    _status = Status.authenticated;
    notifyListeners();
    return true;

  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

}
