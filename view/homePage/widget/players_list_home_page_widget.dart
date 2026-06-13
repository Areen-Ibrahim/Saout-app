import 'dart:io'; // مطلوب لاستخدام FileImage
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/color.dart';

class PlayersListHomePageWidget extends StatelessWidget {
  final String playerName; // اسم اللاعب
  final String playerCountry; // بلد اللاعب
  final String? playerImageUrl; // رابط صورة اللاعب (يمكن أن يكون فارغاً)
  final void Function() onTap;
  final void Function() onChart;
  final void Function() onFile;

  // تمرير البيانات عبر المُنشئ
   PlayersListHomePageWidget({
    super.key,
    required this.playerName,
    required this.playerCountry,
    this.playerImageUrl,
    required this.onTap, // جعل الحقل اختيارياً
     required this.onChart,
     required this.onFile
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: ColorApp.oasisGreen, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onFile,
                  icon: Icon(Icons.file_copy, color: Colors.white, size: 19,),
                ),
                IconButton(
                  onPressed: onChart,
                  icon: Icon(Icons.bar_chart, color: Colors.white, size: 19,),
                ),

              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35, // حجم الصورة
                  backgroundImage: _getImageProvider(), // استخدام الدالة للحصول على نوع الصورة
                ),
                SizedBox(height: 5),
                // عرض اسم اللاعب
                Text(
                  playerName,
                  style: TextStyle(color: Colors.black, fontSize: 13,
                  fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // أيقونة البلد
                      // Icon(Icons.flag, color: Colors.white, size: 15),
                      SizedBox(width: 7),
                      // عرض بلد اللاعب
                      Text(
                        playerCountry,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
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
      return AssetImage("image/avatar.png"); // صورة افتراضية
    }
  }
}
