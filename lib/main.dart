import 'package:book_store/firebase_options.dart';
import 'package:book_store/route_observer.dart';
import 'package:book_store/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Book Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFDEDEDE)),
        textTheme: GoogleFonts.openSansTextTheme(),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF121212),
          contentTextStyle: TextStyle(color: Color(0xFFDEDEDE), fontSize: 16),
          actionTextColor: Color(0xFFDEDEDE),
          behavior: SnackBarBehavior.floating, // Optional: makes it float
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
      ),
      initialRoute: AppRoutes.splashScreen,
      routes: AppRoutes.routes,
    );
  }
}
