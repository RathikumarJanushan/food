import 'package:flutter/material.dart';
import 'package:food_order/view/admin/add/Breakfast.dart';
import 'package:food_order/view/admin/add/dinar.dart';
import 'package:food_order/view/admin/add/lunch.dart';

import '../../common/color_extension.dart';

// Import the Dinar page

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
      "name": "lunch",
      "image": "assets/img/menu_2.png",
    },
    {
      "name": "Dinar",
      "image": "assets/img/menu_3.png",
    },
  ];
  TextEditingController txtSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 180),
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
                  const SizedBox(
                    height: 46,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Menu",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
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
                            } else if (mObj["name"] == "lunch") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => lunchPage()),
                              );
                            } else if (mObj["name"] == "Dinar") {
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
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(17.5),
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
                      }))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
