import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  final SharedPreferences prefs;
  final FirebaseDatabase firebaseDatabase;
  final FirebaseStorage firebaseStorage;

  SettingProvider({
    required this.prefs,
    required this.firebaseDatabase,
    required this.firebaseStorage,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadFile(File image, String fileName) {
    final reference = firebaseStorage.ref().child(fileName);
    final uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataRealtimeDatabase(String ref,String path, Map<String, dynamic> dataNeedUpdate) {
    return FirebaseDatabase.instance.ref(ref).child(path).update(dataNeedUpdate);
  }


}
