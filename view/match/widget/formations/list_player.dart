import 'dart:io';

import 'package:flutter/material.dart';


class ListPlayer extends StatelessWidget {
final String playerName;
final String? imagePlayer;
final String formation;
final void Function() onTap;
   const ListPlayer({super.key,
     required this.playerName,
     required this.imagePlayer,
     required this.formation,
     required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading:  CircleAvatar(
         radius: 40, // حجم الصورة
              backgroundImage: _getImageProvider(), // استخدام الدالة للحصول على نوع الصورة
            ),
          title: Text(playerName, style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600
          ),),
          subtitle: Text(formation, style: TextStyle(
              color: Colors.white
          ),),
          onTap: onTap,
        ),
        Divider(),
      ],
    );
  }
ImageProvider _getImageProvider() {
  if (imagePlayer != null && imagePlayer!.isNotEmpty) {
    if (imagePlayer!.startsWith('http')) {
      return NetworkImage(imagePlayer!); // إذا كان الرابط من الإنترنت
    } else {
      return FileImage(File(imagePlayer!)); // إذا كان الرابط ملف محلي
    }
  } else {
    return AssetImage("image/avatar.png"); // صورة افتراضية
  }
}
}
