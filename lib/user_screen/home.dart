import 'package:book_store/user_screen/pages/single_book.dart';
import 'package:book_store/user_screen/pages/user_home.dart';
import 'package:flutter/material.dart';
import 'package:book_store/services/book_services.dart';
import 'package:book_store/models/book_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/wishlist_services.dart';
import 'package:book_store/user_screen/pages/cart_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String? userId;
  List<BookModel> wishlistBooks = [];
  bool isLoadingWishlist = false;

  final List<String> _titles = [
    'Happy Reading!',
    'Categories',
    'Cart',
    'Account',
  ];

  Future<void> _loadUserAndWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid') ?? '';
    await _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    if (userId == null || userId!.isEmpty) return;

    setState(() {
      isLoadingWishlist = true;
    });

    final bookIds = await WishlistService.getWishlistForUser(userId!);
    List<BookModel> books = [];

    for (final id in bookIds) {
      final book = await BookService.getBookById(id['bookId']!);
      if (book != null) books.add(book);
    }

    setState(() {
      wishlistBooks = books;
      isLoadingWishlist = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserAndWishlist();
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (index) {
          case 0:
            page = const HomeSupportPage();
            break;
          case 1:
            page = const Center(child: CircularProgressIndicator());
            break;
          case 2:
            page = const CartPage();
            break;
          case 3:
            page = const Center(child: CircularProgressIndicator());
            break;
          default:
            page = const Center(child: Text("Unknown"));
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = _navigatorKeys[_selectedIndex].currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.pop();
          } else {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DrawerHeader(
                child: Text(
                  "Your Wishlist",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Wrap the list in Expanded to avoid centering and allow full height usage
              if (isLoadingWishlist)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (wishlistBooks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Your wishlist is empty."),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: wishlistBooks.length,
                    itemBuilder: (context, index) {
                      final book = wishlistBooks[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8
                        ),
                        leading: Image.network(
                          book.imageUrl ?? '',
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(book.title ?? 'No Title'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookSingle(bookId: book.id!),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await WishlistService.removeFromWishlist(
                              userId!,
                              book.id!,
                            );
                            setState(() {
                              wishlistBooks.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from wishlist"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

              // Optional: button at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Optional: navigate to a full wishlist screen
                  },
                  child: const Text("View Full Wishlist"),
                ),
              ),
            ],
          ),
        ),

        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(4, _buildTabNavigator),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0D0D0D),
          unselectedItemColor: Colors.black54,
          backgroundColor: const Color(0xffE6E6E6),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
