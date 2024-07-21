import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class BreakfastPage extends StatefulWidget {
  @override
  _BreakfastPageState createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
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

    FirebaseFirestore.instance.collection('breakfast').add({
      'food': food,
      'price': price,
      'imageUrl': imageUrl,
    }).then((value) {
      print("Data added successfully");
      Fluttertoast.showToast(
        msg: "Data added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to add data: $error");
    });
  }

  void updateDataInFirestore(String docId, String? imageUrl) {
    String food = foodController.text;
    String price = priceController.text;

    FirebaseFirestore.instance.collection('breakfast').doc(docId).update({
      'food': food,
      'price': price,
      'imageUrl': imageUrl,
    }).then((value) {
      print("Data updated successfully");
      Fluttertoast.showToast(
        msg: "Data updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to update data: $error");
    });
  }

  void deleteDataFromFirestore(String docId) {
    FirebaseFirestore.instance
        .collection('breakfast')
        .doc(docId)
        .delete()
        .then((value) {
      print("Data deleted successfully");
      Fluttertoast.showToast(
        msg: "Data deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }).catchError((error) {
      print("Failed to delete data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Breakfast Food'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('breakfast').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: data['imageUrl'] != null
                    ? Image.network(data['imageUrl'], width: 100, height: 100)
                    : Icon(Icons.fastfood),
                title: Text(data['food']),
                subtitle: Text('Price: ${data['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        foodController.text = data['food'];
                        priceController.text = data['price'];
                        _image = null; // Clear image selection
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Update Breakfast'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _image == null
                                    ? Text('No image selected.')
                                    : Image.file(_image!, height: 200),
                                RoundButton(
                                  title: "Select New Image",
                                  onPressed: getImageFromGallery,
                                ),
                                TextField(
                                  controller: foodController,
                                  decoration: InputDecoration(
                                      labelText: 'Enter Food Name'),
                                ),
                                TextField(
                                  controller: priceController,
                                  decoration:
                                      InputDecoration(labelText: 'Enter Price'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text('Update'),
                                onPressed: () async {
                                  String? imageUrl = _image != null
                                      ? await uploadImageToFirebase()
                                      : data['imageUrl'];
                                  updateDataInFirestore(
                                      docs[index].id, imageUrl);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteDataFromFirestore(docs[index].id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          foodController.clear();
          priceController.clear();
          _image = null; // Clear image selection
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Breakfast Food'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image == null
                      ? Text('No image selected.')
                      : Image.file(_image!, height: 200),
                  RoundButton(
                    title: "Select Food Image",
                    onPressed: getImageFromGallery,
                  ),
                  TextField(
                    controller: foodController,
                    decoration: InputDecoration(labelText: 'Enter Food Name'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Enter Price'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    String? imageUrl = await uploadImageToFirebase();
                    saveDataToFirestore(imageUrl);
                  },
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
