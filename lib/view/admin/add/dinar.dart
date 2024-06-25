import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Import this package

class dinarPage extends StatefulWidget {
  @override
  _dinarPageState createState() => _dinarPageState();
}

class _dinarPageState extends State<dinarPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController foodController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadImageToFirebase() async {
    if (_image == null) return null;

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = storageReference.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  void saveDataToFirestore(String? imageUrl) {
    if (imageUrl == null) return;

    String food = foodController.text;
    String price = priceController.text;

    FirebaseFirestore.instance.collection('dinar').add({
      'food': food,
      'price': price,
      'imageUrl': imageUrl,
    }).then((value) {
      print("Data added successfully");
      // Show toast message indicating data added successfully
      Fluttertoast.showToast(
        msg: "Data added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      // Navigate back to the previous page
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to add data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add dinar Food'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(
                      _image!,
                      height: 200,
                    ),
              SizedBox(height: 20),
              RoundButton(
                title: "Select Food Image",
                onPressed: getImageFromGallery,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: foodController,
                  decoration: InputDecoration(
                    labelText: 'Enter Food Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Enter price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              SizedBox(height: 20),
              RoundButton(
                title: "Upload Image and Save Data",
                onPressed: () async {
                  String? imageUrl = await uploadImageToFirebase();
                  saveDataToFirestore(imageUrl);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
