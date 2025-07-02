import 'package:book_store/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_store/services/checkout_services.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final String userId;

  const CheckoutPage({super.key, required this.userId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? shippingAddress;
  String? billingAddress;
  String selectedPaymentMethod = 'Cash on Delivery';
  double totalAmount = 0.0;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
    fetchCartItems();
  }

  Future<void> fetchUserAddress() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get();
    setState(() {
      shippingAddress = doc['shippingAddress'];
      billingAddress = doc['billingAddress'];
    });
  }

  Future<void> fetchCartItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Cart')
        .where('user-id', isEqualTo: widget.userId)
        .get();

    double total = 0;
    final items = snapshot.docs.map((doc) {
      final data = doc.data();
      total += double.tryParse(data['final-price'].toString()) ?? 0;
      return data;
    }).toList();

    setState(() {
      cartItems = items;
      totalAmount = total;
    });
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
                            .doc(widget.userId)
                            .update({'shippingAddress': fullAddress});

                        Navigator.pop(context);
                        fetchUserAddress();
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

  Future<void> updateBillingAddress() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Enter Billing Address"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Save"),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update({'billingAddress': result});
      fetchUserAddress();
    }
  }

  void handlePayNow() async {
    if (shippingAddress == null || shippingAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a delivery address before proceeding.'),
        ),
      );
      return;
    }

    if (billingAddress == null || billingAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a billing address before proceeding.'),
        ),
      );
      return;
    }

    final invoiceNum = DateTime.now().millisecondsSinceEpoch.toString();
    for (final item in cartItems) {
      await CheckoutService.placeOrder(
        userId: widget.userId,
        bookId: item['book-id'].toString(),
        price: item['final-price'].toString(),
        quantity: item['quantity'],
        invoiceNum: invoiceNum,
      );
    }

    final cartSnapshot = await FirebaseFirestore.instance
        .collection('Cart')
        .where('user-id', isEqualTo: widget.userId)
        .get();

    for (final doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed with Invoice #$invoiceNum')),
    );

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.thanks, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivering Address",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (shippingAddress != null && shippingAddress!.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        shippingAddress!,
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
              ElevatedButton(
                onPressed: updateAddress,
                child: Text("Add a New Delivery Address"),
              ),

            const SizedBox(height: 20),
            Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: Text('Cash on Delivery'),
              value: 'Cash on Delivery',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: handlePayNow,
                child: Text(
                  "Pay Rs ${NumberFormat('#,##0.00').format(totalAmount)}",
                  style: TextStyle(color: Color(0xFFDEDEDE)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
