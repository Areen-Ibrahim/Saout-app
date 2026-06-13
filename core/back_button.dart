import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget{
  final void   Function() onPressed;
  final String textBtn;

  const BackButtonWidget({super.key,
    required this.onPressed,
    required this.textBtn});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ), child: Text(textBtn),

    );
  }

}