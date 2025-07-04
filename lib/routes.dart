import 'package:book_store/admin_screen/addbook.dart';
import 'package:book_store/admin_screen/viewbook.dart';
import 'package:book_store/auth_screen/login.dart';
import 'package:book_store/auth_screen/register.dart';
import 'package:book_store/includes/splash.dart';
import 'package:book_store/user_screen/home.dart';
import 'package:book_store/user_screen/landing.dart';
import 'package:book_store/user_screen/pages/all_books.dart';
import 'package:book_store/user_screen/pages/cart_page.dart';
import 'package:book_store/user_screen/pages/thanks.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String addBook = '/add-book';
  static const String viewBook = '/view-books';
  static const String viewCart = '/view-cart';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String allBook = '/home/books';
  static const String thanks = '/thanks';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    addBook: (context) => const Addbook(),
    viewBook: (context) => const ViewBooks(),
    viewCart: (context) => const CartPage(),
    landing: (context) => const Landing(),
    login: (context) => const Login(),
    register: (context) => const Register(),
    home: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      int initialIndex = 0;
      if (args is int) {
        initialIndex = args;
      }
      return UserHomePage(initialIndex: initialIndex);
    },
    allBook: (context) => const AllBooks(),
    thanks: (context) => const Thanks(),
  };
}
