import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseStorage firebaseStorage;
  String imageUrl = "";
  @override
  void initState() {
    super.initState();
    firebaseStorage = FirebaseStorage.instance;
    Reference storageRef = firebaseStorage.ref();
    Reference imageRef = storageRef.child('images/tower-2.jpeg');
    getImageUrl(imageRef);
  }

  void getImageUrl(Reference ref) async {
    imageUrl = await ref.getDownloadURL();
    setState(() {});
  }

  File? _image;
  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(returnedImage!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: _image == null
                ? Container()
                : Image.file(
                    _image!,
                    fit: BoxFit.fill,
                  ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ElevatedButton(
                onPressed: () {
                  _pickImageFromGallery();
                },
                child: Text('Picked Image')),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                  )
                : Container(),
          ),
          Container()
        ],
      ),
    );
  }
}
