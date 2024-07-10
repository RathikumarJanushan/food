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

                    return ListTile(
                      title: Text(coinName),
                      subtitle:
                          Text('Value: $coinValue coins = \$$dollarValue'),
                    );
                  },
                );
              },
            ),
    );
  }
}
