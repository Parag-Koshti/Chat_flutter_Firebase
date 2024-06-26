import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator; // Validator function

  MyTextField({
    Key? key,
    required this.errorText,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Use TextFormField for validation support
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.grey[100],
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      validator: validator, // Set validator function
      onChanged: onChanged,
    );
  }
}
