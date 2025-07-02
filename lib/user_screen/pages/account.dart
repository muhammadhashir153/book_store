import 'package:book_store/routes.dart';
import 'package:book_store/services/checkout_services.dart';
import 'package:book_store/services/user_service.dart';
import 'package:book_store/user_screen/pages/single_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? userId;
  bool isLoading = true;
  bool isLogin = false;
  Map<String, dynamic> userData = {};
  List orderData = [];

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
  }

  Future<void> _getOrderHistory() async {
    await _getUserId();
    final history = await CheckoutService.getOrdersForUser(userId!);
    setState(() {
      orderData = history;
      isLoading = false;
      print('Order History: $orderData');
    });
  }

  Future<void> _getUserData() async {
    await _getUserId();
    if (userId == null) {
      setState(() {
        isLogin = false;
        isLoading = false;
      });
      return;
    }

    final data = await UserService.getUserData(userId!);
    if (data != null) {
      setState(() {
        userData = data;
        isLogin = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLogin = true;
        isLoading = false;
        userData = {};
      });
    }
  }

  Future<void> updateAddress() async {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final postalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: streetController,
                    decoration: InputDecoration(labelText: 'Street Address'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: postalController,
                    decoration: InputDecoration(labelText: 'Postal Code'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF121212),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final street = streetController.text.trim();
                        final city = cityController.text.trim();
                        final postal = postalController.text.trim();

                        if (street.isEmpty || city.isEmpty || postal.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('All fields are required')),
                          );
                          return;
                        }

                        final fullAddress = '$street, $city, $postal';

                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userId)
                            .update({'shippingAddress': fullAddress});

                        await _getUserData();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Save Address",
                        style: TextStyle(color: Color(0xFFDEDEDE)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading && !isLogin
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
          ? Center(child: Text("User Data not found for ID: $userId"))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            userData['profileImage'],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.person, size: 150),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFF121212),
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFDEDEDE),
                              ),
                              label: const Text(
                                "Edit Profile",
                                style: TextStyle(color: Color(0xFFDEDEDE)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                UserService.logoutUser();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.landing,
                                  (route) => false,
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFF121212),
                                ),
                              ),
                              icon: const Icon(
                                Icons.logout,
                                color: Color(0xFFDEDEDE),
                              ),
                              label: const Text(
                                "Logout",
                                style: TextStyle(color: Color(0xFFDEDEDE)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Saved Address",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if ((userData['shippingAddress'] ?? '').toString().isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFF121212),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              userData['shippingAddress'],
                              style: TextStyle(
                                color: Color(0xFFDEDEDE),
                                fontSize: 20,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          TextButton(
                            onPressed: updateAddress,
                            child: Text(
                              "Change",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        "No Address saved! Edit the profile and add an address.",
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    "Your Order History",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderData.length,
                      itemBuilder: (context, index) {
                        final order = orderData[index];
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF121212)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Order ID: ${order['invoice-num']}"),
                                  const SizedBox(height: 8),
                                  Text("Status: ${order['status']}"),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SingleOrder(order: order),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                            Color(0xFF121212),
                                          ),
                                    ),
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                        color: Color(0xFFDEDEDE),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(order['timestamp']),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
