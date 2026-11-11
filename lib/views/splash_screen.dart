// Splash Flutter yang memperlihatkan logo dan indikator putar saat persiapan.
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfffaf8f3),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/megabot_peoplebot_logo.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 20),
          const Text(
            'Megabot-Peoplebot Control',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff526b80),
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          if (errorMessage == null)
            const SizedBox.square(
              dimension: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: Color(0xff86bdb3),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xffa45e68)),
              ),
            ),
        ],
      ),
    ),
  );
}
