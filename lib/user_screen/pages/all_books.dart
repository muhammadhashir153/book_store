import 'package:book_store/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_store/services/wishlist_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllBooks extends StatefulWidget {
  const AllBooks({super.key});

  @override
  State<AllBooks> createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  List _books = [];
  String? userId;

  Future<void> _fetchBooks() async {
    final fetchedBooks = await BookService.getAllBooks();
    setState(() {
      _books = fetchedBooks;
    });
  }

  Future<void> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getString('uid') ?? '';
    final String role = prefs.getString('role') ?? 'user';

    
    // if (uid.isNotEmpty && role != 'user') {
    //   _route = AppRoutes.viewBook; // you can define this route
    // } else if (uid.isNotEmpty && role == 'user') {
    //   _route = AppRoutes.home;
    // }
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
     _decideRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Books")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _books.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Color(0xFFF5F5F5),
                            height: 300,
                            child: Image.network(
                              book.imageUrl ?? '',
                              width: 120,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text(
                                        'Rs ${NumberFormat('#,##0.00').format(double.tryParse(book.price ?? '0') ?? 0)}',
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFDEDEDE),
                                        ),
                                        child: const Text(
                                          'Read More',
                                          style: TextStyle(
                                            color: Color(0xFF121212),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                         onPressed: () async {
  if (userId == null || userId!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  final bookId = _books[index].id;
  await WishlistService.addToWishlist(userId!, bookId);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Added to wishlist")),
  );
},
                                        icon: Icon(
                                          Icons.favorite_border,
                                          color: Color(0xFFDEDEDE),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.shopping_cart,
                                          color: Color(0xFFDEDEDE),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
