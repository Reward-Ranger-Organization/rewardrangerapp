import 'package:flutter/material.dart';
import 'package:rewardrangerapp/screen/signup_screen.dart';

class SignUpOptionsScreen extends StatelessWidget {
  const SignUpOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up Options')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(isPhoneAuth: true),
                  ),
                );
              },
              child: const Text('Sign Up with Phone'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(isPhoneAuth: false),
                  ),
                );
              },
              child: const Text('Sign Up with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
