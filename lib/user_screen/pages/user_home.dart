import 'package:book_store/includes/book_carousel.dart';
import 'package:book_store/user_screen/pages/all_books.dart';
import 'package:flutter/material.dart';

class HomeSupportPage extends StatefulWidget {
  const HomeSupportPage({super.key});

  @override
  State<HomeSupportPage> createState() => _HomeSupportPageState();
}

class _HomeSupportPageState extends State<HomeSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 24, top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 24, bottom: 16),
                child: Text(
                  "Best Deals",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              BookCarousel(topic: 'latest', type: 'deals'),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.only(right: 24, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top Books",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => AllBooks()));
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BookCarousel(topic: 'top book'),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.only(right: 24, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Books",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => AllBooks()));
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BookCarousel(topic: 'latest'),
            ],
          ),
        ),
      ),
    );
  }
}
