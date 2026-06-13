import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/color.dart';

class TitleMatchWidget extends StatelessWidget {
  final String title;
  const TitleMatchWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.only(bottom: 12, right: 70, top: 12, left: 12),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        // color: Colors.yellow,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: ColorApp.richLavender,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
    );
  }
}
