import 'package:book_store/user_screen/pages/user_home.dart';
import 'package:flutter/material.dart';
import 'package:book_store/services/book_services.dart';
import 'package:book_store/models/book_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/services/wishlist_services.dart';

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
    final book = await BookService.getBookById(id);
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
            page = const Center(child: CircularProgressIndicator());
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
            children: [
              const DrawerHeader(child: Text("Your Cart")),
              const ListTile(title: Text("Item 1")),
              const ListTile(title: Text("Item 2")),
              ElevatedButton(onPressed: () {}, child: const Text("Checkout")),
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
