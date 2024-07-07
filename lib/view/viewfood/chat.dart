import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToCartPage extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final String userId;

  const AddToCartPage(
      {required this.foodData, required this.userId, super.key});

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Added to cart')));
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add to cart: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Cart'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                widget.foodData['food'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '\$${widget.foodData['price']}',
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
    );
  }
}
