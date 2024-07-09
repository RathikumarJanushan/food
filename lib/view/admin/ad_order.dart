import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_order/view/admin/SelectMinutesScreen.dart';

class adminViewOrderScreen extends StatelessWidget {
  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          List<DocumentSnapshot> orderItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              DocumentSnapshot order = orderItems[index];
              String userId = order['userId'];
              List<dynamic> items = order['items'];
              double totalPrice = order['totalPrice'];
              Timestamp timestamp = order['timestamp'];
              String address = order['address'];

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
                        'Address: $address',
                        style: TextStyle(
                          fontSize: 16,
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectMinutesScreen(order: order),
                            ),
                          );
                        },
                        child: Text('Select Minutes and Ship'),
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
}
