import 'package:book_store/user_screen/pages/user_home.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late PageController _pageController;
  final List<String> _titles = ['Home', 'Categories', 'Cart', 'Account'];
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onNavTapped(int index) {
    _pageController.jumpToPage(index);
    _selectedIndex = index;
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Text("Your Cart")),
            ListTile(title: Text("Item 1")),
            ListTile(title: Text("Item 2")),
            ElevatedButton(onPressed: () {}, child: Text("Checkout")),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomeSupportPage(),
          Center(child: Text('Categories Page')),
          Center(child: Text('Cart Page')),
          Center(child: Text('Account Page')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0D0D0D),
        unselectedItemColor: Colors.black54,
        backgroundColor: Color(0xffE6E6E6),
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
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
