import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';

class SingleOrder extends StatefulWidget {
  final Map<String, dynamic> order;
  const SingleOrder({super.key, required this.order});

  @override
  State<SingleOrder> createState() => _SingleOrderState();
}

class _SingleOrderState extends State<SingleOrder> {
  List<Map<String, dynamic>> enrichedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrderItems();
  }

  Future<void> loadOrderItems() async {
    List<Map<String, dynamic>> temp = [];

    for (final item in widget.order['books']) {
      final String bookId = item['book-id'];
      final int quantity = item['quantity'];
      final double price = double.tryParse(item['price'].toString()) ?? 0;

      BookModel? book = await BookService.getBookById(bookId);
      if (book != null) {
        temp.add({'book': book, 'quantity': quantity, 'price': price});
      }
    }

    setState(() {
      enrichedItems = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: enrichedItems.length,
              itemBuilder: (context, index) {
                final item = enrichedItems[index];
                final BookModel book = item['book'];
                final int quantity = item['quantity'];
                final double total = item['price'] * quantity;

                return Container(
                  height: 230,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 230,
                            color: Colors.grey[800],
                            child: const Icon(Icons.book, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.genre ?? '',
                                style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.title ?? 'No Title',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.authorName ?? 'Unknown Author',
                                style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Qty: $quantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Rs ${NumberFormat('#,##0.00').format(total)}',
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
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
