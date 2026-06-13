import 'package:flutter/material.dart';

import '../../../../core/color.dart';

class TextFormLoginWidget extends StatelessWidget {
  final String text;
  final String hint;
  final TextEditingController controller;
  final Color colorText;
  final FormFieldValidator<String>? validator;
  final TextInputType? type;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool readOnly;
  const TextFormLoginWidget({super.key,
    required this.text,
    required this.hint,
    required this.controller,
    required this.colorText,
    this.validator,
    this.type,
    this.focusNode,
    this.onTap,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16.0, color: colorText),
        ),
        const SizedBox(height: 10),
        TextFormField(
          readOnly: readOnly,
          onTap: onTap,
          controller: controller,
          validator: validator,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          focusNode: focusNode,
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
