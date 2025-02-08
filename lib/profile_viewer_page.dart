import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewerPage extends StatefulWidget {
  const ProfileViewerPage({super.key});

  @override
  State<ProfileViewerPage> createState() => _ProfileViewerPageState();
}

class _ProfileViewerPageState extends State<ProfileViewerPage> {
  File? _selectedImage;

  void showSnackBar(Widget content,
      {SnackBarBehavior behavior = SnackBarBehavior.fixed}) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(SnackBar(
      content: content,
      showCloseIcon: true,
      closeIconColor: Colors.redAccent,
      behavior: behavior,
    ));
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.square,
              hideBottomControls: true,
            ),
          ]);

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
        storeImage();
      } else {
        Fluttertoast.showToast(msg: "No image selected");
      }
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> storeImage() async {
    final SharedPreferencesWithCache sharedPreferences =
        await SharedPreferencesWithCache.create(
            cacheOptions:
                SharedPreferencesWithCacheOptions(allowList: {"path"}));

    await sharedPreferences.setString("path", _selectedImage!.path);

    Fluttertoast.showToast(msg: "Image saved");
  }

  Future<void> getImage() async {
    final SharedPreferencesWithCache sharedPreferences =
        await SharedPreferencesWithCache.create(
            cacheOptions:
                SharedPreferencesWithCacheOptions(allowList: {"path"}));

    setState(() {
      _selectedImage = File(sharedPreferences.getString("path")!);
    });
  }

  @override
  Widget build(BuildContext context) {
    getImage();
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: _selectedImage != null
                  ? FileImage(File(_selectedImage!.path))
                  : AssetImage("assets/user.jpg"),
            ),
            Positioned(
                right: 10,
                bottom: 0,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: IconButton(
                    onPressed: () {
                      showSnackBar(
                        Row(
                          children: [
                            Text("Select source"),
                            SizedBox(
                              width: 52,
                            ),
                            TextButton(
                                onPressed: () {
                                  pickImage(ImageSource.camera);
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                },
                                child: Text(
                                  "Camera",
                                  style: TextStyle(color: Colors.blueAccent),
                                )),
                            TextButton(
                                onPressed: () {
                                  pickImage(ImageSource.gallery);
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                },
                                child: Text(
                                  "Gallery",
                                  style: TextStyle(color: Colors.blueAccent),
                                )),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
