import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator

import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SecurityService {
  final _controller = StreamController<bool>.broadcast();

  SecurityService();

  Stream<bool> get securityStatusStream => _controller.stream;

  void startSecurityCheck(BuildContext context) {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      bool isJailbroken = false;
      bool isDeveloperMode = false;

      try {
        isJailbroken = await FlutterJailbreakDetection.jailbroken;
      } catch (e) {
        // Handle the error appropriately
        print("Error checking jailbreak status: $e");
      }

      try {
        isDeveloperMode = await _isDeveloperMode();
      } catch (e) {
        // Handle the error appropriately
        print("Error checking developer mode: $e");
      }

      if (isJailbroken || isDeveloperMode) {
        // Show alert dialog and exit app
        _showSecurityAlertAndExitApp(context);
      } else {
        _controller.add(true);
      }
    });
  }

  Future<bool> _isDeveloperMode() async {
    final deviceInfo = DeviceInfoPlugin();
    if (await deviceInfo.androidInfo.then((value) => value.isPhysicalDevice)) {
      // Replace this with actual developer mode detection logic for Android.
      return false; // For example purposes, always returns false.
    }
    if (await deviceInfo.iosInfo.then((value) => value.isPhysicalDevice)) {
      // Replace this with actual developer mode detection logic for iOS.
      return false; // For example purposes, always returns false.
    }
    return false;
  }

  void _showSecurityAlertAndExitApp(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Security Alert',
              style: TextStyle(color: Color.fromARGB(255, 235, 30, 15))),
          content:
              const Text('Your device is jailbroken or in developer mode.\nPlease exit the app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop(); // Dismiss the dialog
                SystemNavigator.pop(); // Exit the app
              },
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _controller.close();
  }
}
