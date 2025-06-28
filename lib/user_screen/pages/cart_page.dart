import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/cart_services.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userId;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCart();
  }

  Future<void> _loadUserIdAndCart() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
    if (userId != null) {
      await _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    final items = await CartService.getCartForUser(userId!);
    setState(() {
      cartItems = items;
    });
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return;

    final item = cartItems[index];
    final unitPrice = (double.tryParse(item['finalPrice']) ?? 0) /
        (item['quantity'] as int);
    final newPrice = (unitPrice * newQuantity).toStringAsFixed(2);

    await CartService.updateCartItem(
      userId: userId!,
      bookId: item['bookId'],
      quantity: newQuantity,
      finalPrice: newPrice,
    );

    await _fetchCartItems();
  }

  Future<void> _removeItem(int index) async {
    final item = cartItems[index];
    await CartService.removeFromCart(userId!, item['bookId']);
    await _fetchCartItems();
  }

  double _calculateTotal() {
    return cartItems.fold(
        0,
        (total, item) =>
            total + (double.tryParse(item['finalPrice']) ?? 0));
  }

  void _goToCheckout() {
    Navigator.pushNamed(context, '/checkout'); // or use a widget directly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("Book ID: ${item['bookId']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Quantity: ${item['quantity']}, Total: Rs ${item['finalPrice']}"),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => _updateQuantity(
                                            index, item['quantity'] - 1),
                                      ),
                                      Text("${item['quantity']}"),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => _updateQuantity(
                                            index, item['quantity'] + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Total: Rs ${NumberFormat('#,##0.00').format(_calculateTotal())}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _goToCheckout,
                            child: const Text("Proceed to Checkout"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
