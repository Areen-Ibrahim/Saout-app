import 'package:flutter/material.dart';

class DropDownGender extends StatelessWidget{
  final String? selectedGender;
  final String text;
  final List<String> item;
  final void Function(String?)? onChange;
  const DropDownGender({super.key,
    required this.selectedGender,
    required this.onChange,
    required this.text,
    required this.item});

  @override
  Widget build(BuildContext context) {
    return   DropdownButtonFormField<String>(
      value: selectedGender,
      hint: Text(text),
      items: item.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChange,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

}