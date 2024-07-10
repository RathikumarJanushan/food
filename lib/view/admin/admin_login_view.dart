import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'package:food_order/common_widget/round_textfield.dart';
import 'package:food_order/view/admin/admin_main_tabview.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({Key? key}) : super(key: key);

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  Future<void> _adminLogin() async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('admin');
      QuerySnapshot querySnapshot = await users
          .where('email', isEqualTo: txtEmail.text.trim())
          .where('password', isEqualTo: txtPassword.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User found, navigate to AdminMainTabView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMainTabView(),
          ),
        );
      } else {
        // User not found, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect email or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: media.height,
        width: media.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/splash_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                Text(
                  "Admin Login",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  "Add Admin details to login",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Admin Email",
                  controller: txtEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Admin Password",
                  controller: txtPassword,
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                RoundButton(
                  title: "Admin Login",
                  onPressed: _adminLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
