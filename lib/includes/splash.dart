import 'package:book_store/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _route = AppRoutes.landing;

  Future<void> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();

    final String uid = prefs.getString('uid') ?? '';
    final String role = prefs.getString('role') ?? 'user';

    print(role);
    print(uid);
    if (uid.isNotEmpty && role == 'admin') {
      _route = AppRoutes.viewBook;
    } else if (uid.isNotEmpty && role == 'user') {
      _route = AppRoutes.home;
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, _route);
    }
  }

  @override
  void initState() {
    super.initState();
    _decideRoute(); // start decision logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Image.asset("assets/images/loader.gif"),
      ),
    );
  }
}
