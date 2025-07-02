import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/cart_services.dart';
import 'package:book_store/user_screen/pages/checkout_page.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userId;
  List<Map<String, dynamic>> cartItems = [];
  List<BookModel> _allBooks = [];
  bool isLoading = true;
  bool isExpanded = false;

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
      _fetchBooksFromCart();
    });
  }

  Future<void> _fetchBooksFromCart() async {
    List<BookModel> books = [];
    for (final item in cartItems) {
      final book = await BookService.getBookById(item['bookId']);
      if (book != null) {
        setState(() {
          books.add(book);
        });
      }
    }
    setState(() {
      isLoading = false;
      _allBooks.addAll(books);
    });
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return;

    final item = cartItems[index];
    final unitPrice =
        (double.tryParse(item['finalPrice']) ?? 0) / (item['quantity'] as int);
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
      (total, item) => total + (double.tryParse(item['finalPrice']) ?? 0),
    );
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutPage(userId: userId!)),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Color(0xFFDEDEDE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xFF121212), size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(Size(28, 28)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (cartItems.isEmpty || _allBooks.isEmpty)
            ? const Center(
                child: Text(
                  "Your cart is empty.",
                  style: TextStyle(fontSize: 18),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final book = _allBooks.firstWhere(
                          (b) => b.id == item['bookId'],
                          orElse: () => BookModel.empty,
                        );
                        return Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0XFF121212),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.imageUrl ?? '',
                                  width: 120,
                                  height: 230,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Genre
                                          Text(
                                            book.genre ?? 'No Genre',
                                            style: const TextStyle(
                                              color: Color(0xFFDEDEDE),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Title
                                          Text(
                                            book.title ?? 'No Title found',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: Color(0xFFDEDEDE),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Author
                                          Text(
                                            book.authorName ?? 'No Author',
                                            style: const TextStyle(
                                              color: Color(0xFFDEDEDE),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          // Quantity and Price Row
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  _quantityButton(
                                                    icon: Icons.remove,
                                                    onPressed: () {
                                                      _updateQuantity(
                                                        index,
                                                        item['quantity'] - 1,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${item['quantity']}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _quantityButton(
                                                    icon: Icons.add,
                                                    onPressed: () {
                                                      _updateQuantity(
                                                        index,
                                                        item['quantity'] + 1,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Rs ${NumberFormat('#,##0.00').format(double.tryParse(item['finalPrice']) ?? 0)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Close Button
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () => _removeItem(index),
                                          icon: const Icon(
                                            Icons.close,
                                            color: Color(0xFFDEDEDE),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Order Summary",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF121212),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Text(
                              isExpanded ? "View Less" : "View Details",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isExpanded ? 120 : 20,
                        child: ListView(
                          shrinkWrap: true,
                          physics: isExpanded
                              ? NeverScrollableScrollPhysics()
                              : ClampingScrollPhysics(),
                          children: cartItems.map((item) {
                            final book = _allBooks.firstWhere(
                              (b) => b.id == item['bookId'],
                              orElse: () => BookModel.empty,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['quantity']}x ${book.title ?? "Unknown Book"}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    'Rs ${NumberFormat('#,##0.00').format(double.tryParse(item['finalPrice']) ?? 0)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      Divider(thickness: 1, color: Colors.grey[300]),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rs ${NumberFormat('#,##0.00').format(_calculateTotal())}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0XFF121212),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: _goToCheckout,
                          child: const Text(
                            "Proceed to Checkout",
                            style: TextStyle(color: Color(0xFFDEDEDE)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
