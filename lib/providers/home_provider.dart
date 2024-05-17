import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/firestore_constants.dart';

class HomeProvider {
  final FirebaseDatabase firebaseDatabase;

  HomeProvider({required this.firebaseDatabase});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseDatabase.ref().child(collectionPath).child(path).update(dataNeedUpdate);
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Future<void> registerNotification(String currentUserId) async {
    NotificationSettings settings= await
    _firebaseMessaging.requestPermission(
      alert: true,
      sound: true,
      carPlay: false,
      announcement: false,
      criticalAlert: false,
      provisional: false
    );
    //
    // FirebaseMessaging.onMessage.listen((message) {
    //   print('onMessage: $message');
    //   if (message.notification != null) {
    //     _showNotification(message.notification!);
    //   }
    //   return;
    // });

    _firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null) {
        HomeProvider(firebaseDatabase: firebaseDatabase)
            .updateDataFirestore(FirestoreConstants.pathUserCollection,
            currentUserId, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  void showNotification(RemoteNotification remoteNotification) async {
    final androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      Platform.isAndroid ? 'com.example.intelivita_task'
          : 'com.example.intelivita_task',
      'Flutter chat demo',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    print(remoteNotification);

    await _flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

Future<void> sendNotification(String token,String body,String title) async {
    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send',),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAq-H_ViM:APA91bEPJ3geHSXYnYWxme2smqZVRED-skZAj51PIIiKYM4Gba4DTJE8FwNT9eF8kiJq5dEl0Sf_o-T0SrwmcWg4sV5kH4as77ny4DW3bvUtnc0rL339Uv9jpsjjbs504Emy_iPRB_tf'

        }
        ,body: jsonEncode(<String,dynamic>{
'priority':"high",
        "data":<String,dynamic>{
  "click_action":"FLUTTER_NOTIFICATION CLICK",
          "status":'done',
          "body":body,
          "title":title,
        },
        "notification":<String,dynamic>{
          "body":body,
          "title":title,
          "android_channel_id":"mit"

        },
        "to":token

      })
      );
      print('Notification send success');

    }catch(e,t){
      print('error $e');
      print('trace $t');
    }

}
}
