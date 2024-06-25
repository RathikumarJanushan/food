import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_order/common_widget/round_button.dart';

class CartScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('cart');

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            cartCollection.where('userId', isEqualTo: user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is empty.'));
          }

          List<DocumentSnapshot> cartItems = snapshot.data!.docs;

          // Calculate total price
          double totalPrice = cartItems.fold(0, (total, item) {
            String priceString = item['price'];
            double price = double.tryParse(priceString) ?? 0.0;
            int quantity = item['quantity'];
            return total + (price * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot item = cartItems[index];
                    String food = item['food'];
                    String priceString = item['price'];
                    double price = double.tryParse(priceString) ?? 0.0;
                    int quantity = item['quantity'];

                    return ListTile(
                      title: Text(food),
                      subtitle: Text(
                          'Price: \$${(price * quantity).toStringAsFixed(2)}'),
                      trailing: Text('Quantity: $quantity'),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              RoundButton(title: "Pay Now", onPressed: () {}),
              const SizedBox(
                height: 30,
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
