import 'dart:convert';

import 'package:book_store/routes.dart';
import 'package:book_store/services/checkout_services.dart';
import 'package:book_store/services/user_service.dart';
import 'package:book_store/user_screen/pages/single_order.dart';
import 'package:book_store/user_screen/pages/update_pass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  Map<String, dynamic> updatedData = {};
  List orderData = [];
  String? _isImageChanged;

  Future<String> uploadCoverImage(XFile imageFile) async {
    const apiKey = '65cc0244b560b957fa8a47cc812a6963';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final response = await http.post(
      uri,
      body: {
        'image': base64Image,
        'name': 'book_cover_${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['url'];
    } else {
      throw Exception('Image upload failed: ${response.body}');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final newImage = await uploadCoverImage(picked);

      setState(() {
        _isImageChanged = newImage;
      });

      updatedData['profileImage'] = newImage;
      await UserService.updateUserData(userId!, updatedData);
      await _getUserData();
    }
  }

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
        updatedData = data;
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
                        if (mounted) {
                          Navigator.pop(context);
                        }
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
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: _isImageChanged != null
                                    ? Image.network(
                                        _isImageChanged!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        userData['profileImage'] ?? '',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person, size: 150),
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: const Offset(
                                    0,
                                    0,
                                  ), // Overlap by 50% look
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF121212),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Color(0xFFDEDEDE),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),

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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdatePass(userId: userId),
                                  ),
                                );
                              },
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
                                "Change Password",
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
