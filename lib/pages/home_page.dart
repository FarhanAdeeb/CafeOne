import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/item_model.dart';
import 'package:my_chat_app/models/user_model.dart';
import 'package:my_chat_app/pages/add_item.dart';
import 'package:my_chat_app/pages/chat_show_page.dart';
import 'package:my_chat_app/pages/edit_item.dart';
import 'package:my_chat_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> updateItem(ItemModel itemModel) async {
    bool value = triggerValue(itemModel.isAvailable);

    itemModel.isAvailable = value;
    await FirebaseFirestore.instance
        .collection("menu")
        .doc(itemModel.itemId)
        .set(itemModel.toMap());
  }

  bool triggerValue(bool value) {
    if (value) {
      value = false;
    } else {
      value = true;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (widget.userModel.role == "Admin")
            ? Text("${widget.userModel.role} view")
            : const Text("Menu"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: (widget.userModel.role == "Admin")
                  ? FirebaseFirestore.instance.collection("menu").snapshots()
                  : FirebaseFirestore.instance
                      .collection("menu")
                      .where("isAvailable", isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      return ListView.builder(
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userMap =
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>;
                          ItemModel itemModel = ItemModel.fromMap(userMap);
                          if (itemModel.itemName!.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 04, horizontal: 10),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: (itemModel.isAvailable)
                                      ? Colors.blue
                                      : Colors.blueGrey,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    (widget.userModel.role == "Admin")
                                        ? {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return EditItem(
                                                      itemModel: itemModel);
                                                },
                                              ),
                                            )
                                          }
                                        : null;
                                  },
                                  onLongPress: () async {
                                    (widget.userModel.role == "Admin")
                                        ? {
                                            await updateItem(itemModel),
                                            setState(() {})
                                          }
                                        : null;
                                  }, //yahan pr availibility set hogoi},
                                  leading: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Image.network(
                                        itemModel.itemPic!,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    itemModel.itemName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    "${itemModel.itemPrice!}   ",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return const Center(
                        child: Center(
                          child: Text(
                            "No results found!",
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Center(
                        child: Text(
                          "An error occoured!",
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Text(
                      "No results found!",
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: (widget.userModel.role == "Admin")
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AddItem(
                                firebaseUser: widget.firebaseUser,
                                userModel: widget.userModel,
                              );
                            }));
                          },
                          child: const Text("Add Item")))
                ],
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatSHowPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.chat_bubble),
      ),
    );
  }
}
