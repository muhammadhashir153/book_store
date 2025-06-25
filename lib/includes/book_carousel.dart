import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookCarousel extends StatefulWidget {
  final String? topic;
  const BookCarousel({super.key, required this.topic});

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: SizedBox(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                  );
                },
              ),
      ),
    );
  }
}
