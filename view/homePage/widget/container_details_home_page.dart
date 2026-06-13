import 'package:flutter/material.dart';

class ContainerDetailsHomePage extends StatelessWidget {
  final IconData iconData;
  final String   numberSt;
  final String   textSt;
  const ContainerDetailsHomePage({
    super.key,
    required this.iconData,
    required this.numberSt,
    required this.textSt});

  @override
  Widget build(BuildContext context) {
    return   Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData, color: Colors.black45, size: 22,),
        SizedBox(height: 9),
        Text(numberSt,style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),),
        SizedBox(height: 5),
        Text(textSt,style: TextStyle(color: Colors.black87, fontSize: 12),),

      ],
    );
  }
}
