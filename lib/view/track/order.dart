import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/round_button.dart';

class MergedOrderCheckoutScreen extends StatefulWidget {
  final List<DocumentSnapshot> cartItems;
  final double totalPrice;

  MergedOrderCheckoutScreen(
      {required this.cartItems, required this.totalPrice});

  @override
  _MergedOrderCheckoutScreenState createState() =>
      _MergedOrderCheckoutScreenState();
}

class _MergedOrderCheckoutScreenState extends State<MergedOrderCheckoutScreen> {
  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('cart');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List paymentArr = [
    {"name": "Pay with QR", "icon": "assets/img/cash.png"},
    {"name": "**** **** **** ****", "icon": "assets/img/visa_icon.png"},
    {"name": "****@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  int selectMethod = -1;
  String address = "";

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardDateController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController emailController = TextEditingController();

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment method",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: paymentArr.length,
                        itemBuilder: (context, index) {
                          var pObj = paymentArr[index] as Map? ?? {};
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: TColor.textfield,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color:
                                        TColor.secondaryText.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Image.asset(pObj["icon"].toString(),
                                    width: 50, height: 20, fit: BoxFit.contain),
                                // const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pObj["name"],
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMethod = index;
                                    });
                                  },
                                  child: Icon(
                                    selectMethod == index
                                        ? Icons.radio_button_on
                                        : Icons.radio_button_off,
                                    color: TColor.primary,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                    Visibility(
                      visible: selectMethod == 0,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Image.asset(
                            'assets/img/paynow.png',
                            width: 150,
                            height: 150,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectMethod == 1,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardNumberController,
                            decoration: InputDecoration(
                              labelText: "Card Number",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardDateController,
                            decoration: InputDecoration(
                              labelText: "Expiry Date",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardCVVController,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectMethod == 2,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
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
              RoundButton(
                title: "Pay Now",
                onPressed: () async {
                  List<Map<String, dynamic>> items =
                      widget.cartItems.map((item) {
                    return {
                      'food': item['food'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                    };
                  }).toList();

                  // Add order to Firestore
                  await orderCollection.add({
                    'userId': user.uid,
                    'items': items,
                    'totalPrice': widget.totalPrice,
                    'timestamp': FieldValue.serverTimestamp(),
                    'address': address, // Add user's address
                  });

                  // Delete items from cart collection
                  for (DocumentSnapshot doc in widget.cartItems) {
                    await cartCollection.doc(doc.id).delete();
                  }

                  // Update user's coins
                  DocumentReference coinRef = FirebaseFirestore.instance
                      .collection('coins')
                      .doc(user.uid);

                  // Get current coin balance
                  DocumentSnapshot coinSnapshot = await coinRef.get();
                  double currentCoins = coinSnapshot.exists
                      ? (coinSnapshot['coins'] ?? 0.0)
                      : 0.0;

                  // Add total price to current coin balance
                  double updatedCoins = currentCoins + widget.totalPrice;

                  // Save updated coin balance to Firestore
                  await coinRef.set({'coins': updatedCoins});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Order added successfully! Coins updated.')),
                  );

                  Navigator.pop(context); // Navigate back to cart or home
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
