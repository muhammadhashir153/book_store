import 'package:book_store/routes.dart';
import 'package:book_store/services/book_services.dart';
import 'package:book_store/user_screen/pages/single_book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_store/services/wishlist_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/cart_services.dart';

class AllBooks extends StatefulWidget {
  const AllBooks({super.key});

  @override
  State<AllBooks> createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  List _books = [];
  List _allBooks = [];
  String? userId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _allGenres = [];
  String? _selectedGenre;

  Future<void> _fetchBooks() async {
    final allBooks = await BookService.getAllBooks();

    final genres = allBooks
        .map((book) => book.genre ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _allBooks = allBooks;
      _allGenres = genres;

      _books = allBooks.where((book) {
        final query = _searchQuery.toLowerCase();
        return book.title?.toLowerCase().contains(query) == true ||
            book.authorName?.toLowerCase().contains(query) == true;
      }).toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _fetchBooks();
  }

  Future<void> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getString('uid') ?? '';
  }

  Set<String> _wishlistBookIds = {};

  Future<void> toggleWishlist(BuildContext context, String bookId) async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    if (_wishlistBookIds.contains(bookId)) {
      await WishlistService.removeFromWishlist(userId!, bookId);
      if (mounted) {
        setState(() {
          _wishlistBookIds.remove(bookId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removed from wishlist")));
      }
    } else {
      await WishlistService.addToWishlist(userId!, bookId);
      if (mounted) {
        setState(() {
          _wishlistBookIds.add(bookId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to wishlist")));
      }
    }
  }

  Future<void> _fetchWishlist() async {
    if (userId != null && userId!.isNotEmpty) {
      final fetchedWishlist = await WishlistService.getWishlistForUser(userId!);
      setState(() {
        _wishlistBookIds = fetchedWishlist
            .map<String>((bookMap) => bookMap['bookId']!)
            .toSet();
      });
    }
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

    final book = _books[index];
    final bookId = book.id;
    final price = book.price ?? '0';

    bool isAdded = await CartService.addToCart(
      userId: userId!,
      bookId: bookId,
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
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Color(0xFFDEDEDE),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.home,
                arguments: 1,
              );
            },
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
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _searchController.addListener(_onSearchChanged);
    await _decideRoute();
    await _fetchBooks();
    await _fetchWishlist();
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Books",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// Genre Filter
          Text("Genre"),
          const SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedGenre,
            hint: Text("Select Genre"),
            items: _allGenres.map((genre) {
              return DropdownMenuItem<String>(value: genre, child: Text(genre));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGenre = value;
                _books = _allBooks
                    .where((book) => book.genre == value)
                    .toList();
              });
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 16),

          /// Price Sorting
          Text("Sort by Price"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _books.sort(
                        (a, b) => double.tryParse(
                          a.price ?? '0',
                        )!.compareTo(double.tryParse(b.price ?? '0')!),
                      );
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121212),
                    foregroundColor: const Color(0xFFDEDEDE), // Text color
                  ),
                  child: const Text("Low to High"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _books.sort(
                        (a, b) => double.tryParse(
                          b.price ?? '0',
                        )!.compareTo(double.tryParse(a.price ?? '0')!),
                      );
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121212),
                    foregroundColor: const Color(0xFFDEDEDE), // Text color
                  ),
                  child: const Text("High to Low"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedGenre = null;
                  _books = [..._allBooks];
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF121212),
                foregroundColor: const Color(0xFFDEDEDE), // Text color
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Clear Filters"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Books")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search Books",
                        fillColor: Color(0XFFDEDEDE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF121212)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF121212),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF121212),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (context) => _buildFilterSheet(context),
                        );
                      },
                      icon: Icon(Icons.filter_list),
                      color: Color(0xFFDEDEDE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔁 Books list
              ..._books.map((book) {
                final index = _books.indexOf(book);
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                BookSingle(bookId: book.id),
                                          ),
                                        );
                                      },
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
                                      onPressed: () {
                                        toggleWishlist(context, book.id);
                                      },
                                      icon: Icon(
                                        _wishlistBookIds.contains(book.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            _wishlistBookIds.contains(book.id)
                                            ? Colors.red
                                            : Color(0xFFDEDEDE),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        _addToCart(index);
                                      },
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
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
