import 'package:book_store/firebase_options.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Book Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFDEDEDE)),
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
