import 'package:book_store/routes.dart';
import 'package:flutter/material.dart';

class Thanks extends StatefulWidget {
  const Thanks({super.key});

  @override
  State<Thanks> createState() => _ThanksState();
}

class _ThanksState extends State<Thanks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
            ),
            const Spacer(),
            // Check icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order received!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been validated.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
