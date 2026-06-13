import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String text;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator; // متغير للتحقق من صحة الإدخال
  final TextInputType inputType; // متغير لنوع البيانات المدخلة
  final String? errorText;

  const TextFormFieldWidget({
    super.key,
    required this.text,
    required this.hint,
    required this.controller,
    this.validator, // إضافة المتغير هنا
    this.inputType = TextInputType.text, // القيمة الافتراضية هي نص عادي
    this.errorText
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        const SizedBox(height: 10),
        TextFormField( // استخدام TextFormField

          controller: controller,
          validator: validator, // إضافة المتغير هنا
          keyboardType: inputType, // إضافة نوع البيانات المدخلة
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            filled: true,
            fillColor: Colors.white
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
