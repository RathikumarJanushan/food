import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_order/view/admin/add/Breakfast.dart';
import 'package:food_order/view/admin/add/dinar.dart';
import 'package:food_order/view/admin/add/lunch.dart';
import 'package:food_order/common/color_extension.dart';

class AddMenuView extends StatefulWidget {
  const AddMenuView({super.key});

  @override
  State<AddMenuView> createState() => _AddMenuViewState();
}

class _AddMenuViewState extends State<AddMenuView> {
  List menuArr = [
    {
      "name": "Breakfast",
      "image": "assets/img/menu_1.png",
    },
    {
      "name": "Lunch",
      "image": "assets/img/menu_2.png",
    },
    {
      "name": "Dinner",
      "image": "assets/img/menu_3.png",
    },
  ];
  TextEditingController txtSearch = TextEditingController();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to the login screen after logout
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/img/splash_bg.png"), // Your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            width: media.width * 0.27,
            height: media.height * 0.6,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Add the logo here
                  Container(
                    margin: const EdgeInsets.only(top: 10), // Adjusted margin
                    child: Image.asset(
                      "assets/img/logo.jpeg", // Your logo asset path
                      width: 100,
                      height: 100,
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: menuArr.length,
                    itemBuilder: ((context, index) {
                      var mObj = menuArr[index] as Map? ?? {};
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the appropriate page based on the menu item clicked
                          if (mObj["name"] == "Breakfast") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BreakfastPage()),
                            );
                          } else if (mObj["name"] == "Lunch") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => lunchPage()),
                            );
                          } else if (mObj["name"] == "Dinner") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => dinarPage()),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 20),
                              width: media.width - 100,
                              height: 90,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 7,
                                        offset: Offset(0, 4))
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  mObj["image"].toString(),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mObj["name"].toString(),
                                        style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(17.5),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2))
                                      ]),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/img/btn_next.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
