import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';

class AddToCartPage extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final String userId;

  const AddToCartPage({required this.foodData, required this.userId, Key? key})
      : super(key: key);

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _saveToFirestore() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('cart').add({
        'userId': widget.userId,
        'food': widget.foodData['food'],
        'price': widget.foodData['price'],
        'track': 'add',
        'quantity': int.parse(_quantityController.text),
      }).then((_) {
        Flushbar(
          message: 'Added to cart',
          duration: Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context).then((_) {
            Navigator.pop(context);
          });
      }).catchError((error) {
        Flushbar(
          message: 'Failed to add to cart: $error',
          duration: Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Cart'),
      ),
      body: Container(
        height: media.height,
        width: media.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/splash_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.foodData['food'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '\RM${widget.foodData['price']}',
                  style: TextStyle(fontSize: 20, color: Colors.green[700]),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    } else if (int.tryParse(value) == null ||
                        int.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveToFirestore,
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
