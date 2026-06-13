import 'package:flutter/material.dart';

class NextButtonWidget extends StatelessWidget{
  final void Function() onPressed;
  final bool loading;

  const NextButtonWidget({super.key,
    required this.onPressed,
    required this.loading});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child: loading
          ? CircularProgressIndicator() // عرض مؤشر التحميل
          : Text('Next'),
    );
  }

}