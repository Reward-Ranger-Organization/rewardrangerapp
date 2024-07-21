import 'package:flutter/material.dart';

import '../screen/contact_support.dart';

class DrawerScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  const DrawerScreen({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(223, 6, 0, 42),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color.fromARGB(99, 27, 9, 184), // Background color of the avatar
            child: Text(
              firstName.isNotEmpty
                  ? firstName[0].toUpperCase()
                  : '', // First letter of the first name
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            firstName,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'user@example.com',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          _buildListTile(Icons.support, 'Contact Support', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactSupport()),
            );
          }),
          const SizedBox(height: 30),
          _buildListTile(Icons.person_add, 'Refer and Earn', () {
            // Handle refer and earn action
          }),
          const Spacer(),
          _buildListTile(Icons.logout_rounded, 'Log Out', () {
            // Handle logout action
          }, textColor: const Color.fromARGB(255, 0, 174, 255)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String text, void Function()? onTap, {Color? textColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color.fromARGB(255, 0, 234, 255), width: 0.7),
      ),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 0, 234, 255),
              size: 30,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: textColor ?? const Color.fromARGB(255, 0, 234, 255),
              letterSpacing: 2,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
