import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class adminShipScreen extends StatelessWidget {
  final CollectionReference shipCollection =
      FirebaseFirestore.instance.collection('ship');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ready to Ship Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: shipCollection.snapshots(),
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
                      ...items.map((item) {
                        String food = item['food'];
                        double price = double.tryParse(item['price']) ?? 0.0;
                        int quantity = item['quantity'];

                        return ListTile(
                          title: Text(food),
                          subtitle: Text(
                              'Price: \$${price.toStringAsFixed(2)} x $quantity'),
                          trailing: Text(
                              'Total: \$${(price * quantity).toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        'Total Price: \$${totalPrice.toStringAsFixed(2)}',
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
