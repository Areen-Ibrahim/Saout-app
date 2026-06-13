import 'package:flutter/material.dart';

class TextFormAddPlayer extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final String? Function(String?)? validator; // إضافة المدقق
  final String? errorText;
   final TextInputType? type;
  const TextFormAddPlayer({
    super.key,
    required this.controller,
    required this.text,
    this.validator,
    this.errorText, // إضافة المدقق
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: type,
          controller: controller,
          decoration: InputDecoration(
            labelText: text,
            labelStyle: TextStyle(color: Colors.white),
            errorText: errorText,
          ),
          style: TextStyle(color: Colors.white), // لون النص داخل الحقل
          cursorColor: Colors.white,
          validator: validator, // إضافة المدقق
        ),
        SizedBox(height: 6),
      ],
    );
  }
}
