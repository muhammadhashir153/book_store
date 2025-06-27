import 'package:book_store/admin_screen/addbook.dart';
import 'package:book_store/admin_screen/viewbook.dart';
import 'package:book_store/auth_screen/login.dart';
import 'package:book_store/auth_screen/register.dart';
import 'package:book_store/includes/splash.dart';
import 'package:book_store/user_screen/home.dart';
import 'package:book_store/user_screen/landing.dart';
import 'package:book_store/user_screen/pages/all_books.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String addBook = '/add-book';
  static const String viewBook = '/view-books';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String allBook = '/home/books';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    addBook: (context) => const Addbook(),
    viewBook: (context) => const ViewBooks(),
    landing: (context) => const Landing(),
    login: (context) => const Login(),
    register: (context) => const Register(),
    home: (context) => const UserHomePage(),
    allBook: (context) => const AllBooks(),
  };
}
