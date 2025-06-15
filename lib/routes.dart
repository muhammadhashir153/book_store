import 'package:book_store/admin_screen/addbook.dart';
import 'package:book_store/auth_screen/login.dart';
import 'package:book_store/auth_screen/register.dart';
import 'package:book_store/includes/splash.dart';
import 'package:book_store/user_screen/landing.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String addBook = '/add-book';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    addBook: (context) => const Addbook(),
    landing: (context) => const Landing(),
    login: (context) => const Login(),
    register: (context) => const Register(),
  };
}
