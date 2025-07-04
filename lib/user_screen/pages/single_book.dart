import 'package:book_store/models/book_models.dart';
import 'package:book_store/services/book_services.dart';
import 'package:book_store/services/review_service.dart';
import 'package:book_store/user_screen/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/cart_services.dart';
import 'package:book_store/services/checkout_services.dart';

class BookSingle extends StatefulWidget {
  final String bookId;
  const BookSingle({super.key, required this.bookId});

  @override
  State<BookSingle> createState() => _BookSingleState();
}

class _BookSingleState extends State<BookSingle> {
  BookModel? _book;
  bool isLoading = true;
  bool? isLiked;
  bool isLoadingReviews = true;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];

  Future<void> _fetchBooks() async {
    final fetchedBooks = await BookService.getBookById(widget.bookId);
    setState(() {
      _book = fetchedBooks;
      isLoading = false;
    });
  }

  Future<void> _addReview() async {
    FocusScope.of(context).unfocus();

    final bookId = widget.bookId;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('uid') ?? '';
    final review = _reviewController.text;
    final rating = isLiked == true ? 5.0 : 0.0;

    try {
      await ReviewService.addReview(
        bookId: bookId,
        userId: userId,
        comment: review,
        rating: rating,
        isLiked: isLiked!,
      );
      _reviewController.clear();
      setState(() {
        isLiked = null;
      });
      await _fetchReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review added successfully")),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final fetchedReviews = await ReviewService.getReviewsForBook(
        widget.bookId,
      );
      setState(() {
        reviews = fetchedReviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoadingReviews = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchReviews();
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
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('uid') ?? '';

    final success = await CartService.addToCart(
      userId: userId,
      bookId: _book!.id ?? '',
      quantity: 1,
      finalPrice: _book!.price ?? '0',
    );
if (success && mounted) {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutPage(userId: userId!)),
    );
}
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF121212),
  ),
  child: const Text(
    'Buy Now',
    style: TextStyle(color: Color(0xFFDEDEDE)),
  ),
),
                                    const SizedBox(width: 8),
                                   IconButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('uid') ?? '';

    final success = await CartService.addToCart(
      userId: userId,
      bookId: _book!.id ?? '',
      quantity: 1,
      finalPrice: _book!.price ?? '0',
    );

    if (success && mounted) {
      Navigator.pushNamed(context, '/view-cart'); // Make sure this route is defined
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Book already in cart or failed to add")),
      );
    }
  },
  icon: Icon(Icons.shopping_cart, color: Color(0xFF121212)),
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
                    SizedBox(height: 16),
                    Text(
                      "Leave a comment about this book",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLiked = true;
                            });
                          },
                          icon: Icon(
                            isLiked == true
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                          ),
                          color: Color(0xFF121212),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLiked = false;
                            });
                          },
                          icon: Icon(
                            isLiked == false
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                          ),
                          color: Color(0xFF121212),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Your Message",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF121212)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _addReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF121212),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Color(0xFFDEDEDE)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isLoadingReviews
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: reviews.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0XFFDEDEDE),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        review['user']['profileImage'] ?? '',
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            Icon(Icons.person),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review['user']['username'] ??
                                                'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            review['timestamp'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(review['comment'] ?? ''),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
