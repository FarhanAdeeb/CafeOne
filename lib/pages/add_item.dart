import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/models/item_model.dart';
import 'package:my_chat_app/models/ui_helper.dart';
import 'package:my_chat_app/models/user_model.dart';
import 'package:my_chat_app/pages/home_page.dart';
import 'package:uuid/uuid.dart';

class AddItem extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const AddItem({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  String uuid = const Uuid().v1();
  File? imageFile;
  TextEditingController itemNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedIMage = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 10);

    if (croppedIMage != null) {
      setState(() {
        imageFile = croppedIMage;
      });
    }
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a Photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String itemName = itemNameController.text.trim();
    String itemPrice = priceController.text.trim();

    if (itemName == "" || itemPrice == "" || imageFile == null) {
      UIHelper.showAlertDialog(context, "Icomplete Data",
          "Please fill all the fiels and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("itempictures")
        .child(uuid)
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? itemname = itemNameController.text.trim();
    String? itemPrice = priceController.text.trim();
    String? itemId = uuid;

    ItemModel newItem = ItemModel(
        itemId: itemId,
        itemName: itemname,
        itemPrice: itemPrice,
        itemPic: imageUrl);

    await FirebaseFirestore.instance
        .collection("menu")
        .doc(newItem.itemId)
        .set(newItem.toMap())
        .then(
      (value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return HomePage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Add Item"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(
                  labelText: "item Name",
                ),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Item Price",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
