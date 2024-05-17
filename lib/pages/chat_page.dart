import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelivita_task/providers/home_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/date_time.dart';
import '../widgets/loading_view.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.arguments});

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final String _currentUserId;

  String _groupChatId = "";
  String? pushToken = '';
  bool _isLoading = false;

  final _chatInputController = TextEditingController();
  final _focusNode = FocusNode();

  late final _chatProvider = context.read<ChatProvider>();
  late final _authProvider = context.read<AuthProviders>();
  late final _homeProvider = context.read<HomeProvider>();

  @override
  void initState() {
    super.initState();
    _readLocal();
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }


  void _readLocal() {
    if (_authProvider.userFirebaseId?.isNotEmpty == true) {
      _currentUserId = _authProvider.userFirebaseId!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
    String peerId = widget.arguments.peerId;
    if (_currentUserId.compareTo(peerId) > 0) {
      _groupChatId = '$_currentUserId-$peerId';
    } else {
      _groupChatId = '$peerId-$_currentUserId';
    }

    _chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      _currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }



  void _onSendMessage(String content,) {
    if (content.trim().isNotEmpty) {
      _chatInputController.clear();
      _chatProvider.sendMessage(content, _groupChatId, _currentUserId, widget.arguments.peerId);
      _chatProvider.getChatStream(_groupChatId);
      getToken();
      _homeProvider.sendNotification("$pushToken",
          content, "chat app");

    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  void _onBackPress() {
    _chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      _currentUserId,
      {FirestoreConstants.chattingWith: null},
    );
    Navigator.pop(context);
  }
  getToken() async {
    final DatabaseReference userRef = FirebaseDatabase.instance.ref()
        .child('users').child(_currentUserId);
    DataSnapshot tokenSnap = await userRef.get();

    if (tokenSnap.exists) {
      setState(() {
        pushToken = tokenSnap.child('pushToken').value as String?;
        if (pushToken != null) {
          print('Push Token: $pushToken');
        } else {
          print('Push Token not found');
        }
      });

    } else {
      print('User data not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.peerNickname,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PopScope(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildListMessage(),
                  _buildInput(),
                ],
              ),
              Positioned(
                child: _isLoading ? LoadingView() : SizedBox.shrink(),
              ),
            ],
          ),
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            _onBackPress();
          },
        ),
      ),
    );
  }


  Widget _buildInput() {
    return Container(
      child: Row(
        children: [
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (_) {
                },
                style: TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
                controller: _chatInputController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: _focusNode,
              ),
            ),
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _onSendMessage(_chatInputController.text),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget _buildListMessage() {
    return Flexible(
      child: _groupChatId.isNotEmpty
          ?
      StreamBuilder<DatabaseEvent>(
        stream: _chatProvider.getChatStream(_groupChatId),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final event = snapshot.data!;
            if (event.snapshot.value != null) {
              final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
              final List<Map<String, dynamic>> messages = data.entries.map((entry) {
                return Map<String, dynamic>.from(entry.value);
              }).toList();
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemBuilder: (_, index) {
                  print(messages[0]['content']);
                  print(data.length);
                  return

                    Row(
                    mainAxisAlignment:
                    messages[index]['idFrom'].toString() ==
                        _currentUserId.toString() ?
                    MainAxisAlignment.end :
                      MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment:
                    messages[index]['idFrom'].toString() ==
                        _currentUserId.toString() ?
                    CrossAxisAlignment.end :
                    CrossAxisAlignment.start,
                        children: [
                          Card(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                softWrap: true,
                                maxLines: 10,
                                messages[index]['content'].toString()??""),
                          )),
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Text(

                              formatDateTime(int.parse(messages[index]['timestamp'].toString())),
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },

                itemCount: messages.length,
                reverse: false,
              );
            } else {
              return Center(child: Text("No messages here yet..."));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            );
          }
        },
      )




          : Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments({required this.peerId, required this.peerAvatar, required this.peerNickname});
}
