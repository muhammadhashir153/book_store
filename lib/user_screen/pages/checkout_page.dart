import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_store/services/checkout_services.dart';

class CheckoutPage extends StatefulWidget {
  final String userId;

  CheckoutPage({required this.userId});

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
    final doc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();
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
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Enter Delivery Address"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Save")),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
        'shippingAddress': result,
      });
      fetchUserAddress();
    }
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
            child: Text("Save")),
      ],
    ),
  );
  if (result != null && result.isNotEmpty) {
    await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
      'billingAddress': result,
    });
    fetchUserAddress();
  }
}


void handlePayNow() async {
  if (shippingAddress == null || shippingAddress!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please add a delivery address before proceeding.')),
    );
    return;
  }

  if (billingAddress == null || billingAddress!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please add a billing address before proceeding.')),
    );
    return;
  }

  // 🔢 Generate invoice number
  final invoiceNum = DateTime.now().millisecondsSinceEpoch.toString();

  // 🧾 Loop through each item and assign same invoice number
  for (final item in cartItems) {
    await CheckoutService.placeOrder(
      userId: widget.userId,
      bookId: item['book-id'].toString(),
      price: item['final-price'].toString(),
      quantity: item['quantity'],
      invoiceNum: invoiceNum,
    );
  }

  // 🗑️ Clear the cart
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

  Navigator.pop(context, "/home"); // return to previous screen
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Delivering Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (shippingAddress != null && shippingAddress!.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.black,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shippingAddress!, style: TextStyle(color: Colors.white)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: updateAddress,
                        child: Text("Change", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: updateAddress,
                child: Text("Add a New Delivery Address"),
              ),

              const SizedBox(height: 20),
Text("Billing Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
if (billingAddress != null && billingAddress!.isNotEmpty)
  Container(
    padding: EdgeInsets.all(12),
    color: Colors.black,
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(billingAddress!, style: TextStyle(color: Colors.white)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: updateBillingAddress,
            child: Text("Change", style: TextStyle(color: Colors.white)),
          ),
        )
      ],
    ),
  )
else
  ElevatedButton(
    onPressed: updateBillingAddress,
    child: Text("Add a Billing Address"),
  ),
            const SizedBox(height: 20),
            Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            ElevatedButton(
              onPressed: handlePayNow,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text("Pay \$${totalAmount.toStringAsFixed(2)}"),
            ),
          ],
        ),
      ),
    );
  }
}
