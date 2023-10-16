import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
    FirebaseFirestore.instance
        .collection('users')
        .doc("6dgZIYlrlITE9THY7IaNCbSZY092")
        .get()
        .then((value) {
      profilePicUrl = value.get('profilePic');
      setState(() {});
    });
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

  File? pickedImageUrl;
  String profilePicUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                //imagePicker
                var imageFromGallery =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (imageFromGallery == null) return;
                var croppedFile = await ImageCropper().cropImage(
                  sourcePath: imageFromGallery.path,
                  uiSettings: [
                    AndroidUiSettings(
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false),
                    IOSUiSettings(
                      title: 'Cropper',
                    ),
                    WebUiSettings(
                      context: context,
                      presentStyle: CropperPresentStyle.dialog,
                      boundary: const CroppieBoundary(
                        width: 520,
                        height: 520,
                      ),
                      viewPort: const CroppieViewPort(
                          width: 480, height: 480, type: 'circle'),
                      enableExif: true,
                      enableZoom: true,
                      showZoomer: true,
                    ),
                  ],
                );
                if (croppedFile != null) {
                  pickedImageUrl = File(croppedFile.path);
                }
                // pickedImageUrl = File(imageFromGallery.path);
                setState(() {});
              },
              child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: pickedImageUrl != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              pickedImageUrl!,
                            ),
                          )
                        : profilePicUrl != ""
                            ? DecorationImage(
                                image: NetworkImage(profilePicUrl),
                              )
                            : null,
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Sadid Pic',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  var currTime = DateTime.now().millisecondsSinceEpoch;
                  if (pickedImageUrl != null) {
                    var uplaodRef = firebaseStorage
                        .ref()
                        .child("images/profilePic/img_$currTime.jpg");
                    try {
                      uplaodRef.putFile(pickedImageUrl!).then((p0) async {
                        var downloadUrl = await p0.ref.getDownloadURL();
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc("6dgZIYlrlITE9THY7IaNCbSZY092")
                            .collection("profilePic")
                            .add({
                          "profilePic": downloadUrl,
                        }).then((value) =>
                                print('profile picture uploaed to fire store'));

                        FirebaseFirestore.instance
                            .collection('users')
                            .doc("6dgZIYlrlITE9THY7IaNCbSZY092")
                            .update({
                          "profilePic": downloadUrl,
                        }).then((value) =>
                                print('profile picture uploaed to fire store'));
                      });
                    } catch (e) {
                      print('Error : ${e.toString()}');
                    }
                  }
                },
                child: Text('Update Profile')),
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc("6dgZIYlrlITE9THY7IaNCbSZY092")
                  .collection("profilePic")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4),
                    itemBuilder: (context, index) {
                      return Container(
                        child: Image.network(
                            snapshot.data!.docs[index].data()['profilePic']),
                      );
                    },
                  );
                }
                return Container();
              },
            ))
          ],
        ),
      ),
    );
  }
}


// "email":"s1@s.com"
// "id":"6dgZIYlrlITE9THY7IaNCbSZY092"
// "password":"12345678"