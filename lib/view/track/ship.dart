import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'dart:async';

class ShipScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference shipCollection =
      FirebaseFirestore.instance.collection('ship');
  final CollectionReference deliveryCollection =
      FirebaseFirestore.instance.collection('delivery');

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ready to Ship Orders'),
          automaticallyImplyLeading: false, // Removes the back button
        ),
        body: Center(
          child: Text('You are not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ready to Ship Orders'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: shipCollection.where('userId', isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders ready to ship.'));
          }

          List<DocumentSnapshot> shipItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: shipItems.length,
            itemBuilder: (context, index) {
              DocumentSnapshot order = shipItems[index];
              String userId = order['userId'];
              List<dynamic> items = order['items'];
              double totalPrice = order['totalPrice'];
              Timestamp timestamp = order['timestamp'];
              int readyInMinutes = order['readyInMinutes'];
              String address = order['address'];

              DateTime readyTime =
                  timestamp.toDate().add(Duration(minutes: readyInMinutes));
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: $userId',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Order Date: ${timestamp.toDate().toLocal().toString()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$address',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...items.map((item) {
                        String food = item['food'];
                        double price = double.tryParse(item['price']) ?? 0.0;
                        int quantity = item['quantity'];

                        return ListTile(
                          title: Text(food),
                          subtitle: Text(
                              'Price: \RM${price.toStringAsFixed(2)} x $quantity'),
                          trailing: Text(
                              'Total: \RM${(price * quantity).toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        'Total Price: \RM${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ready in: $readyInMinutes minutes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      CountdownTimer(readyTime: readyTime),
                      SizedBox(height: 20),
                      RoundButton(
                        title: "Confirm ",
                        onPressed: () => confirmOrder(context, order),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> confirmOrder(
      BuildContext context, DocumentSnapshot order) async {
    try {
      // Save order details to the 'delivery' collection
      await deliveryCollection.add({
        'userId': order['userId'],
        'items': order['items'],
        'totalPrice': order['totalPrice'],
        'timestamp': order['timestamp'],
        'readyInMinutes': order['readyInMinutes'],
        'address': order['address'],
      });

      // Delete the order from the 'ship' collection
      await order.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order confirmed and moved to delivery!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm the order: $error')),
      );
    }
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime readyTime;

  CountdownTimer({required this.readyTime});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.readyTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = widget.readyTime.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime.isNegative) {
      return Text(
        'delivery completed',
        style: TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      'Time remaining: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
