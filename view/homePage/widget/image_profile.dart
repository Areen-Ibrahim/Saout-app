import 'dart:io'; // مطلوب لاستخدام FileImage
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/color.dart';

class ImageProfile extends StatelessWidget {
  final String? playerImageUrl; // رابط صورة اللاعب (يمكن أن يكون فارغاً)

  // تمرير البيانات عبر المُنشئ
  ImageProfile({
    super.key,
    this.playerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          // border: Border.all(color: ColorApp.yellow, width: 2),
          // shape: BoxShape.circle
        ),
        child: CircleAvatar(
          radius: 40, // حجم الصورة
          backgroundImage: _getImageProvider(), // استخدام الدالة للحصول على نوع الصورة
        ),
      );

  }

  // دالة لتحديد مصدر الصورة بناءً على الرابط (شبكة أو ملف محلي)
  ImageProvider _getImageProvider() {
    if (playerImageUrl != null && playerImageUrl!.isNotEmpty) {
      if (playerImageUrl!.startsWith('http')) {
        return NetworkImage(playerImageUrl!); // إذا كان الرابط من الإنترنت
      } else {
        return FileImage(File(playerImageUrl!)); // إذا كان الرابط ملف محلي
      }
    } else {
      return AssetImage("image/basicicon.png"); // صورة افتراضية
    }
  }
}
