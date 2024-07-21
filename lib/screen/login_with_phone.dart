import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardrangerapp/helper_function/utility.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart';
import 'package:rewardrangerapp/screen/otp_veridication.dart';
import '../widget/text_field.dart'; // Import if not already added

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({super.key});

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId; // Variable to store verification ID

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String phoneNumber = _phoneController.text;

    if (phoneNumber.isEmpty) {
      // Handle empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          // Navigate to dashboard or home screen on successful sign-in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to verify phone number: ${e.message}')),
          );
          logger.e('Failed to verify phone number: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          // Navigate to OTP input screen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EnterOtpScreen(verificationId: _verificationId!, phoneNumber: phoneNumber)),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      logger.e('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Phone'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
