import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/models/item_model.dart';
import 'package:my_chat_app/models/ui_helper.dart';
import 'package:uuid/uuid.dart';

class EditItem extends StatefulWidget {
  final ItemModel itemModel;
  const EditItem({Key? key, required this.itemModel}) : super(key: key);

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  var temp = 0;
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

    if (itemName == "" || itemPrice == "" || imageFile == override) {
      UIHelper.showAlertDialog(context, "Icomplete Data",
          "Please fill all the fiels and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    if (temp == 1) {
      UIHelper.showLoadingDialog(context, "Uploading image..");

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("itempictures")
          .child(widget.itemModel.itemId!)
          .putFile(imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      String? imageUrl = await snapshot.ref.getDownloadURL();
      widget.itemModel.itemPic = imageUrl;
    }

    String? itemname = itemNameController.text.trim();
    String? itemPrice = priceController.text.trim();
    String? itemId = widget.itemModel.itemId!;

    widget.itemModel.itemId = itemId;
    widget.itemModel.itemPrice = itemPrice;
    widget.itemModel.itemName = itemname;

    await FirebaseFirestore.instance
        .collection("menu")
        .doc(widget.itemModel.itemId)
        .set(widget.itemModel.toMap())
        .then(
      (value) {
        Navigator.pop(context);
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    itemNameController.text = widget.itemModel.itemName!;
    priceController.text = widget.itemModel.itemPrice!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Update Item"),
      ),
      body: SafeArea(
        child: Center(
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
                    temp = 1;
                  },
                  padding: const EdgeInsets.all(0),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        (imageFile != null) ? FileImage(imageFile!) : null,
                    foregroundImage: (imageFile == null)
                        ? NetworkImage(widget.itemModel.itemPic!)
                        : null,
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
      ),
    );
  }
}
