import 'package:book_store/routes.dart';
import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  double _opacity = 0.0;
  double _scale = 0.6;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            child: Image.asset("assets/images/main-bg.png", fit: BoxFit.cover),
          ),
          Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.4),
                    Color.fromRGBO(255, 255, 255, 1),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1),
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Color(0xFF121212),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Image.asset(
                            "assets/images/logo.png",
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Read more and stress less with our online book shopping app. Shop from anywhere you are and discover titles that you love. Happy reading!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF252525),
                        ),
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.login,
                            ); // Or any route
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF121212),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(color: Color(0xFFDEDEDE)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.register,
                          ); // Or any route
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Color(0xFF121212)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
