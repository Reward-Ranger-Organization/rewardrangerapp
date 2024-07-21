import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart';
import '../widget/text_field.dart'; // Import if not already added

class EnterOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const EnterOtpScreen({required this.verificationId, required this.phoneNumber, super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text;

    if (otp.isEmpty) {
      // Handle empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Navigate to dashboard or home screen on successful sign-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextField(
              controller: _otpController,
              labelText: 'OTP',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
