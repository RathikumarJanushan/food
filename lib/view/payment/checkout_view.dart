import 'package:flutter/material.dart';
import 'package:food_order/common/color_extension.dart';
import 'package:food_order/common_widget/round_button.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/img/cash.png"},
    {"name": "**** **** **** ****", "icon": "assets/img/visa_icon.png"},
    {"name": "****@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  int selectMethod = -1;
  String address = " ";

  // Controllers for card details and email
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardDateController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void _changeAddress() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController addressController =
            TextEditingController(text: address);
        return AlertDialog(
          title: Text("Change Address"),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(hintText: "Enter new address"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  address = addressController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Address",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 12),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        TextButton(
                          onPressed: _changeAddress,
                          child: Text(
                            "Change",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: TColor.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment method",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: paymentArr.length,
                        itemBuilder: (context, index) {
                          var pObj = paymentArr[index] as Map? ?? {};
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: TColor.textfield,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color:
                                        TColor.secondaryText.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Image.asset(pObj["icon"].toString(),
                                    width: 50, height: 20, fit: BoxFit.contain),
                                // const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pObj["name"],
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),

                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMethod = index;
                                    });
                                  },
                                  child: Icon(
                                    selectMethod == index
                                        ? Icons.radio_button_on
                                        : Icons.radio_button_off,
                                    color: TColor.primary,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                    Visibility(
                      visible: selectMethod == 1,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardNumberController,
                            decoration: InputDecoration(
                              labelText: "Card Number",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardDateController,
                            decoration: InputDecoration(
                              labelText: "Expiry Date",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardCVVController,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectMethod == 2,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              SizedBox(height: 16),
              RoundButton(
                  title: "Pay Now",
                  onPressed: () {
                    // Handle payment processing based on selected method
                    if (selectMethod == 1) {
                      // Process card payment
                      String cardNumber = cardNumberController.text;
                      String cvv = cardCVVController.text;
                      // Add your payment processing logic here
                    } else if (selectMethod == 2) {
                      // Process PayPal payment
                      String email = emailController.text;
                      // Add your payment processing logic here
                    } else {
                      // Process Cash on Delivery
                      // Add your payment processing logic here
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
