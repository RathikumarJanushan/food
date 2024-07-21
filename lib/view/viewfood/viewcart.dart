import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'package:food_order/view/track/order.dart';
import 'package:food_order/view/track/orderwithcoins.dart';

class CartScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final CollectionReference coinsCollection =
      FirebaseFirestore.instance.collection('coins');

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    var media = MediaQuery.of(context).size;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Cart'),
          automaticallyImplyLeading: false, // Removes the back button
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
          child: Center(
            child: Text('You need to log in to view your cart.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        automaticallyImplyLeading: false, // Removes the back button
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
        child: StreamBuilder<QuerySnapshot>(
          stream:
              cartCollection.where('userId', isEqualTo: user.uid).snapshots(),
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

            return StreamBuilder<DocumentSnapshot>(
              stream: coinsCollection.doc(user.uid).snapshots(),
              builder: (context, coinSnapshot) {
                if (coinSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!coinSnapshot.hasData || !coinSnapshot.data!.exists) {
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
                                  'Price: \RM${(price * quantity).toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Quantity: $quantity'),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await cartCollection
                                          .doc(item.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Total Price: \RM${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      RoundButton(
                        title: "Pay Now",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MergedOrderCheckoutScreen(
                                cartItems: cartItems,
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                }

                var coinData =
                    coinSnapshot.data!.data() as Map<String, dynamic>;
                var coinValue = coinData.values.first;
                double dollarValue =
                    (coinValue is int ? coinValue.toDouble() : coinValue) / 100;

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
                                'Price: \RM${(price * quantity).toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Quantity: $quantity'),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await cartCollection.doc(item.id).delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total Price: \RM${totalPrice.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    RoundButton(
                      title: "Pay Now",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MergedOrderCheckoutScreen(
                              cartItems: cartItems,
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Coins: $coinValue   value = \RM${dollarValue.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    RoundButton(
                      title: "Pay with coins",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => orderwithcoins(
                              cartItems: cartItems,
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 60),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
