import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/material.dart';

class BookSingle extends StatefulWidget {
  final String bookId;
  const BookSingle({super.key, required this.bookId});

  @override
  State<BookSingle> createState() => _BookSingleState();
}

class _BookSingleState extends State<BookSingle> {
  BookModel? _book;
  bool isLoading = true;
  Future<void> _fetchBooks() async {
    final fetchedBooks = await BookService.getBookById(widget.bookId);
    setState(() {
      _book = fetchedBooks;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _book!.title ?? 'No Title',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Image.network(
                            _book!.imageUrl ?? '',
                            width: 120,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Author: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                _book?.authorName ??
                                                'No Author Found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Genre: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                _book?.genre ??
                                                'No Genre Found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Price: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                _book?.price ??
                                                'No Price Found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF121212),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF121212),
                                      ),
                                      child: const Text(
                                        'Buy Now',
                                        style: TextStyle(
                                          color: Color(0xFFDEDEDE),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Color(0xFF121212),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _book!.description ?? 'No Description Found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
