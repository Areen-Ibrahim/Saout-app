import 'package:flutter/material.dart';

class TextTitleAddPlayer extends StatelessWidget {
  final String text;
  const TextTitleAddPlayer({super.key,
    required this.text});

  @override
  Widget build(BuildContext context) {
    return  Text(text,
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 19,
        letterSpacing: 1,
        // fontFamily: 'play'
      ),
    );
  }
}
