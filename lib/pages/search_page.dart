import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/main.dart';
import 'package:my_chat_app/models/chatroom_model.dart';
import 'package:my_chat_app/models/user_model.dart';
import 'package:my_chat_app/pages/chatroom_page.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

// class UserMOdel {
//   var email;

//   var uid;

//   var fullname;

//   var profilepic;

//   UserModel(Map<String, dynamic> userMap);
// }

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRooMmodel?> getChatroomModel(UserModel targetUser) async {
    ChatRooMmodel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRooMmodel existingChatroom =
          ChatRooMmodel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      //create a new one
      ChatRooMmodel newChatroom = ChatRooMmodel(
        chatroomid: uuid.v1(),
        lastmessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.tomap());
      chatRoom = newChatroom;
      log("New Chatroom Created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("search"),
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchController.text)
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);
                          return ListTile(
                            onTap: () async {
                              ChatRooMmodel? chatRooMmodel =
                                  await getChatroomModel(searchedUser);

                              if (chatRooMmodel != null) {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    targetUser: searchedUser,
                                    userModel: widget.userModel,
                                    firebaseUser: widget.firebaseUser,
                                    chatroom: chatRooMmodel,
                                  );
                                }));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searchedUser.profilepic!),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(searchedUser.email!),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return Text("No result found!");
                        }
                      } else if (snapshot.hasError) {
                        return Text("An error occured!");
                      } else {
                        return Text("No result found!");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
