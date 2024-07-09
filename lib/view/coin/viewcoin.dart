import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinsViewPage extends StatefulWidget {
  @override
  _CoinsViewPageState createState() => _CoinsViewPageState();
}

class _CoinsViewPageState extends State<CoinsViewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Coins'),
      ),
      body: user == null
          ? Center(child: Text('Not logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('coins').doc(user!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    !snapshot.data!.exists) {
                  return Center(child: Text('No coins found'));
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                var coins = data.keys.toList();

                return ListView.builder(
                  itemCount: coins.length,
                  itemBuilder: (context, index) {
                    String coinName = coins[index];
                    dynamic coinValue = data[coinName];
                    double dollarValue =
                        (coinValue is int ? coinValue.toDouble() : coinValue) /
                            100;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Text(
                          coinName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Value: $coinValue coins = \$$dollarValue',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Add onTap functionality here if needed
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
