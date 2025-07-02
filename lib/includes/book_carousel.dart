import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:book_store/services/cart_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/user_screen/pages/single_book.dart';
import 'package:intl/intl.dart';

class BookCarousel extends StatefulWidget {
  final String? topic;
  final String? type;

  const BookCarousel({super.key, required this.topic, this.type});

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  bool isLoading = true;
  String? userId;

  Future<void> fetchBooks() async {
    books = await BookService.getAllBooks();
    print('Fetched books: ${books.length}');
    print('Topic: ${widget.topic}');

    List<BookModel> tempFiltered = [];

    if (widget.topic == 'top book') {
      books.sort(
        (a, b) => (double.tryParse(b.price ?? '0') ?? 0).compareTo(
          double.tryParse(a.price ?? '0') ?? 0,
        ),
      );
      tempFiltered = books.take(5).toList();
      print("Top books filtered: ${tempFiltered.length}");
    } else if (widget.topic == 'latest') {
      books.shuffle();
      tempFiltered = books.take(5).toList();
      print("Latest books filtered: ${tempFiltered.length}");
    } else {
      tempFiltered = books
          .where(
            (book) => book.genre?.toLowerCase() == widget.topic?.toLowerCase(),
          )
          .toList();
    }

    setState(() {
      filteredBooks = tempFiltered;
      isLoading = false;
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
  }

  Future<void> _addToCart(int index) async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF121212),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text("User not logged in"),
        ),
      );
      return;
    }

    final book = books[index];
    final bookId = book.id;
    final price = book.price ?? '0';

    bool isAdded = await CartService.addToCart(
      userId: userId!,
      bookId: bookId!,
      quantity: 1,
      finalPrice: price,
    );

    if (isAdded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF121212),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            "Added to cart",
            style: TextStyle(color: Color(0xFFDEDEDE)),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF121212),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            "Book already in cart",
            style: TextStyle(color: Color(0xFFDEDEDE)),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
    _loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: widget.type == 'deals'
          ? SizedBox(
              height: 260,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 340,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color(0xFF121212),
                            ),
                            margin: const EdgeInsets.only(right: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  book.imageUrl ?? '',
                                  width: 120,
                                  height: 260,
                                  fit: BoxFit.cover,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.genre ?? 'No Genre',
                                              style: const TextStyle(
                                                color: Color(0xFFF5F5F5),
                                              ),
                                            ),
                                            Text(
                                              book.title ?? 'No Title',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                color: Color(0xFFF5F5F5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              book.authorName ?? 'No Author',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                color: Color(0xFFF5F5F5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Rs ${NumberFormat('#,##0.00').format(double.tryParse(book.price ?? '0') ?? 0)}',
                                          style: const TextStyle(
                                            color: Color(0xFFF5F5F5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _addToCart(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFDEDEDE,
                                            ),
                                          ),
                                          child: const Text(
                                            'Add to Cart',
                                            style: TextStyle(
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          : SizedBox(
              height: 380,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookSingle(bookId: book.id!),
                                ),
                              );
                            },
                            child: Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 16.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    book.imageUrl ?? '',
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      width: double.infinity,
                                      color: Color(0xFF121212),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                book.genre ?? 'No Genre',
                                                style: TextStyle(
                                                  color: Color(0xFFF5F5F5),
                                                ),
                                              ),
                                              Text(
                                                book.title ?? 'No Title',
                                                style: TextStyle(
                                                  color: Color(0xFFF5F5F5),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                book.authorName ?? 'No Author',
                                                style: TextStyle(
                                                  color: Color(0xFFF5F5F5),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Rs ${NumberFormat('#,##0.00').format(double.tryParse(book.price ?? '0') ?? 0)}',
                                            style: TextStyle(
                                              color: Color(0xFFF5F5F5),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
