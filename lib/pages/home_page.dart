import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intelivita_task/pages/settings_page.dart';
import 'package:provider/provider.dart';

import '../constants/firestore_constants.dart';
import '../models/user_chat.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/loading_view.dart';
import 'chat_page.dart';
import 'login_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final _homeProvider = context.read<HomeProvider>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final _databaseReference = FirebaseDatabase.instance.ref();
  late final String _currentUserId;

  List<UserChat> _allUsers = [];
  List<UserChat> _chattedUsers = [];

  bool _isLoading = false;
  late final _authProvider = context.read<AuthProviders>();

  @override
  void initState() {
    super.initState();
    _homeProvider.registerNotification(_authProvider.userFirebaseId.toString());
   _homeProvider.configLocalNotification();
    _registerNotification();
    _configLocalNotification();
    if (_authProvider.userFirebaseId?.isNotEmpty == true) {
      _currentUserId = _authProvider.userFirebaseId!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
        (_) => false,
      );
    }


    _fetchUsers();
    _fetchChattedUsers();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabChange);
  }
  void _handleTabChange() {
    if (_tabController.index == 1) {
      _fetchChattedUsers();
    }
    else {
      _fetchUsers();
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void _registerNotification() {
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage: $message');
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
      return;
    });

    _firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null) {
        _homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, _currentUserId, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void _configLocalNotification() {
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  void _showNotification(RemoteNotification remoteNotification) async {
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


  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    final snapshot = await _databaseReference.child('users').get();
    print('one snap${snapshot.value}');
    final usersMap = snapshot.value as Map<dynamic, dynamic>;

    final currentUser = await FirebaseAuth.instance.currentUser;

    final users = usersMap.entries
        .where((entry) => entry.key != currentUser?.uid)
        .map((entry) => UserChat(
        id: entry.key,
        photoUrl: entry.value['photoUrl'],
        nickname: entry.value['nickname'],
        aboutMe: entry.value['aboutMe']))
        .toList();

    setState(() {
      _allUsers = users;
      _isLoading = false;
    });
  }



  Future<void> _fetchChattedUsers() async {
    final DataSnapshot snapshot = await
    FirebaseDatabase.instance.ref().child('users')
        .child(_currentUserId).
    child('isChatedWith').get();

    try {

      List<UserChat> users = [];

      for (DataSnapshot userId in snapshot.children) {
        print('snapshot for msg user ids is ====  ${userId.value}');
        DataSnapshot userSnapshot =await FirebaseDatabase.instance.ref()
            .child('users').child(userId.value.toString()).get();
        print('User data: ${userSnapshot.value}');
        if (userSnapshot.exists) {
          UserChat userChat = UserChat.fromSnapshot(userSnapshot);
          users.add(userChat);
          print('User data: ${userSnapshot.value}'); // Print the user data
        }
      }

      setState(() {
        _isLoading = false;
        _chattedUsers = users;
        print('Chatted user list: ${_chattedUsers.length}');
      });
    } catch (e,t) {
      print('Error fetching users: $e');
      print('Trace fetching users: $t');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(

      length: 2,

      child: Scaffold(
      appBar: AppBar(
        title: Text('Home'),

        actions: [
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
          }, child: Text('Profile'))
        ],
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Users'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body:

      TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(_allUsers),
          _buildUserList(_chattedUsers),
        ],

      ),
    ));
  }

  Widget _buildUserList(List<UserChat> users) {
    if (_isLoading) {
      return LoadingView();
    } else if (users.isEmpty) {
      return Center(
        child: Text('No users available.'),
      );
    } else {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final  user = users[index];
          return Card(
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl ?? ''),
              ),
              title: Text(user.nickname ?? ''),
              subtitle: Text(user.aboutMe ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(arguments: ChatPageArguments(peerAvatar: user.photoUrl??"",peerId: user.id??"",
                        peerNickname: user.nickname??"")),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}

