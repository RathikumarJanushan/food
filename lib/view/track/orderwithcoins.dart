import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/round_button.dart';

class orderwithcoins extends StatefulWidget {
  final List<DocumentSnapshot> cartItems;
  final double totalPrice;

  orderwithcoins({required this.cartItems, required this.totalPrice});

  @override
  _orderwithcoinsState createState() => _orderwithcoinsState();
}

class _orderwithcoinsState extends State<orderwithcoins> {
  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference coinsCollection =
      FirebaseFirestore.instance.collection('coins');

  int selectMethod = -1;
  String address = "";
  Map<String, dynamic>? coinData;

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardDateController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    User? user = _auth.currentUser;
    super.initState();
    _fetchCoinData();
  }

  void _fetchCoinData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot coinSnapshot = await coinsCollection.doc(user.uid).get();
      if (coinSnapshot.exists) {
        setState(() {
          coinData = coinSnapshot.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  void _changeAddress() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController addressController =
            TextEditingController(text: address);
        return AlertDialog(
          title: Text("Change Address"),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(hintText: "Enter new address"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  address = addressController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _payNow() async {
    if (coinData != null) {
      double totalCoinBalance = coinData!.values
          .map((coinValue) =>
              (coinValue is int ? coinValue.toDouble() : coinValue) / 100)
          .reduce((a, b) => a + b);

      if (totalCoinBalance >= widget.totalPrice) {
        User? user = _auth.currentUser;
        List<Map<String, dynamic>> items = widget.cartItems.map((item) {
          return {
            'food': item['food'],
            'price': item['price'],
            'quantity': item['quantity'],
          };
        }).toList();

        double totalCoinsRequired = widget.totalPrice * 100; // Convert to coins

        // Subtract the total price from the user's coin balance
        coinData!.forEach((coinName, coinValue) async {
          dynamic currentCoinValue = coinValue;
          if (currentCoinValue is int) {
            currentCoinValue = currentCoinValue.toDouble();
          }

          double remainingCoins = currentCoinValue - totalCoinsRequired;

          if (remainingCoins >= 0) {
            await coinsCollection
                .doc(user!.uid)
                .update({coinName: remainingCoins});
            totalCoinsRequired = 0;
          } else {
            await coinsCollection.doc(user!.uid).update({coinName: 0});
            totalCoinsRequired -= currentCoinValue;
          }
        });

        // Add order to Firestore
        await orderCollection.add({
          'userId': user!.uid,
          'items': items,
          'totalPrice': widget.totalPrice,
          'timestamp': FieldValue.serverTimestamp(),
          'address': address, // Add user's address
        });

        // Delete items from cart collection
        for (DocumentSnapshot doc in widget.cartItems) {
          await cartCollection.doc(doc.id).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order added successfully! Coins updated.')),
        );

        Navigator.pop(context); // Navigate back to cart or home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Order'),
        ),
        body: Center(
          child: Text('You need to log in to place an order.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order and Checkout'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone NO & Address",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: _changeAddress,
                          child: Text(
                            "Change",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: TColor.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Order",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot item = widget.cartItems[index];
                        String food = item['food'];
                        String priceString = item['price'];
                        double price = double.tryParse(priceString) ?? 0.0;
                        int quantity = item['quantity'];

                        return ListTile(
                          title: Text(food),
                          subtitle: Text(
                              'Price: \RM${(price * quantity).toStringAsFixed(2)}'),
                          trailing: Text('Quantity: $quantity'),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total Price: \RM${widget.totalPrice.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              SizedBox(height: 16),
              if (coinData != null)
                Column(
                  children: coinData!.keys.map((coinName) {
                    dynamic coinValue = coinData![coinName];
                    double dollarValue =
                        (coinValue is int ? coinValue.toDouble() : coinValue) /
                            100;

                    return Text(
                      'Value: $coinValue coins = \$$dollarValue',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16),
              RoundButton(
                title: "Pay Now",
                onPressed: () {
                  _payNow();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
