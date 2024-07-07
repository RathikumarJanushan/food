import 'package:flutter/material.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/round_button.dart';
import 'package:food_order/view/main_tabview/main_tabview.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  List pageArr = [
    {
      "title": "Find Food You Love",
      "subtitle":
          "the best foods\nrestaurants and fast delivery to your\ndoorstep",
    },
    {
      "title": "Fast Delivery",
      "subtitle": "Fast food delivery to your place, office\n wherever you are",
    },
    {
      "title": "Tracking",
      "subtitle": "tracking of your food on the app\nonce you placed the order",
    },
  ];

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/img/splash_bg.png"), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              itemBuilder: ((context, index) {
                var pObj = pageArr[index] as Map? ?? {};
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: media.width * 0.2,
                    ),
                    Text(
                      pObj["title"].toString(),
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Text(
                      pObj["subtitle"].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: media.width * 0.20,
                    ),
                  ],
                );
              }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: media.height * 0.6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pageArr.map((e) {
                    var index = pageArr.indexOf(e);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                          color: index == selectPage
                              ? TColor.primary
                              : TColor.placeholder,
                          borderRadius: BorderRadius.circular(4)),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: media.height * 0.28,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: RoundButton(
                      title: "Next",
                      onPressed: () {
                        if (selectPage >= 2) {
                          // Home Screen

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainTabView(),
                            ),
                          );
                        } else {
                          //Next Screen

                          setState(() {
                            selectPage = selectPage + 1;
                            controller.animateToPage(selectPage,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.bounceInOut);
                          });
                        }
                      }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
