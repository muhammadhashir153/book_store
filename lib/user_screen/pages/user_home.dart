import 'package:book_store/includes/book_carousel.dart';
import 'package:flutter/material.dart';

class HomeSupportPage extends StatefulWidget {
  const HomeSupportPage({super.key});

  @override
  State<HomeSupportPage> createState() => _HomeSupportPageState();
}

class _HomeSupportPageState extends State<HomeSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: BookCarousel(topic: 'latest'),));
  }
}
