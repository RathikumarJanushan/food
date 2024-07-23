import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_order/common_widget/round_button.dart';

class SelectMinutesScreen extends StatefulWidget {
  final DocumentSnapshot order;

  SelectMinutesScreen({required this.order});

  @override
  _SelectMinutesScreenState createState() => _SelectMinutesScreenState();
}

class _SelectMinutesScreenState extends State<SelectMinutesScreen> {
  final CollectionReference shipCollection =
      FirebaseFirestore.instance.collection('ship');
  int selectedMinutes = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Minutes and Ship'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/img/splash_bg.png"), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('${widget.order['address']}'),
              SizedBox(height: 10),
              Text('User ID: ${widget.order['userId']}'),
              SizedBox(height: 10),
              ...widget.order['items'].map<Widget>((item) {
                return Text(
                  '${item['food']}: \RM${item['price']} x ${item['quantity']}',
                );
              }).toList(),
              SizedBox(height: 10),
              Text('Total Price: \RM${widget.order['totalPrice']}'),
              SizedBox(height: 20),
              DropdownButton<int>(
                value: selectedMinutes,
                items: List.generate(
                  59,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1} minutes'),
                  ),
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              RoundButton(
                onPressed: () async {
                  await shipOrder();
                },
                title: "Ready to Ship",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> shipOrder() async {
    try {
      // Save order details to the 'ship' collection
      await shipCollection.add({
        'userId': widget.order['userId'],
        'items': widget.order['items'],
        'totalPrice': widget.order['totalPrice'],
        'timestamp': widget.order['timestamp'],
        'readyInMinutes': selectedMinutes,
        'address': widget.order['address'],
      });

      // Delete the order from the 'orders' collection
      await widget.order.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order is ready to ship!')),
      );

      // Navigate back to the admin view order screen
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process the order: $error')),
      );
    }
  }
}
