import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "    $labelText",
          labelStyle:
              const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)), // White with 70% opacity
          enabledBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(255, 255, 255, 0.7)), // White with 70% opacity
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // White color for focused border
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onTap: onTap,
      ),
    );
  }
}
