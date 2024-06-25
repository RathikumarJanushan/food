import 'package:flutter/material.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/tab_button.dart';
import 'package:food_order/view/admin/add_menu_view.dart';
import 'package:food_order/view/home/home_view.dart';

class AdminMainTabView extends StatefulWidget {
  const AdminMainTabView({super.key});

  @override
  State<AdminMainTabView> createState() => _AdminMainTabViewState();
}

class _AdminMainTabViewState extends State<AdminMainTabView> {
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const AddMenuView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              selctTab = 2;
              selectPageView = const AddMenuView();
            }
            if (mounted) {
              setState(() {});
            }
          },
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? TColor.primary : TColor.placeholder,
          child: Image.asset(
            "assets/img/tab_home.png",
            width: 30,
            height: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: TColor.white,
        shadowColor: Colors.black,
        elevation: 1,
        notchMargin: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  title: "Order",
                  icon: "assets/img/tab_order.png",
                  onTap: () {
                    if (selctTab != 1) {
                      selctTab = 1;
                      selectPageView = Container();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 1),
              const SizedBox(
                width: 40,
                height: 40,
              ),
              TabButton(
                  title: "Complete Order",
                  icon: "assets/img/tab_order.png",
                  onTap: () {
                    if (selctTab != 3) {
                      selctTab = 3;
                      selectPageView = Container();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 3),
            ],
          ),
        ),
      ),
    );
  }
}
