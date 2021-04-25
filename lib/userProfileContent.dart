import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hello_me/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileContent extends StatefulWidget {
  final AuthRepository? auth;

  UserProfileContent({this.auth});

  @override
  _UserProfileContentState createState() =>
      _UserProfileContentState(auth: auth);
}

class _UserProfileContentState extends State<UserProfileContent> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthRepository? auth;
  static const FILE_NAME = 'avatar.png';

  String? _imageUrl;

  Future<String> _getImageUrl(String name) {
    return _storage.ref('images').child(name).getDownloadURL();
  }

  Future<String> _uploadNewImage(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  @override
  void initState() {
    super.initState();
    String? uid = this.auth!.user?.uid;
    String F_NAME = uid == null ? FILE_NAME : uid + FILE_NAME;
    _getImageUrl(F_NAME).then((value) => setState(() {
      _imageUrl = value;
    }));
  }

  _UserProfileContentState({Key? key, this.auth});


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding( // profile image
            padding: EdgeInsets.only(top: 16.0, left: 16.0),
            child: SizedBox(
              width: 70,
              height: 70,
              child: Container(
                width: 55,
                height: 55,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: _imageUrl == null ?
                SizedBox(
                  width: 55.0,
                  height: 55.0,
                  child: Center(),
                ) : CircleAvatar(
                  backgroundImage: NetworkImage(_imageUrl!),
                  radius: 20,
                ),
              ),
            ),
          ),
          Expanded( // profile mail & change avatar button
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container( //profile mail
                    child: Text(
                      this.auth?.user?.email ?? '',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
                    ),
                  ),
                  Expanded( // change avatar button
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.teal,
                                shadowColor: Colors.grey.withAlpha(50),
                                minimumSize: Size(120.0, 25.0),
                                padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 5.0, right: 5.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  )
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform
                                    .pickFiles(type: FileType.image);

                                if(result != null){
                                  File file = File(result.files.single.path!);
                                  setState(() {
                                    _imageUrl = null;
                                  });
                                  String? uid = this.auth!.user?.uid;
                                  String F_NAME = uid == null ? FILE_NAME : uid + FILE_NAME;
                                  _imageUrl = await _uploadNewImage(file, F_NAME);
                                  setState(() {});
                                }
                                else {
                                  final snackBar = SnackBar(
                                    content: Text('No image selected'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              },
                              child: Text('Change avatar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}