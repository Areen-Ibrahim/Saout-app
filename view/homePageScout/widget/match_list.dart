import 'dart:io';
import 'package:flutter/material.dart';

class MatchList extends StatelessWidget {
  final String matchName;
  final String result;
  final String position;
  final String date;
  final ImageProvider? profile;
  final ImageProvider? profileOP;
  final void Function() onTap;


  const MatchList({
    super.key,
    required this.matchName,
    required this.result,
    required this.position,
    required this.profile,
    required this.date,
    required this.onTap,
    required this.profileOP,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: profileOP,
                  radius: 34,
                ),
                SizedBox(width: 20),
                  CircleAvatar(
                    backgroundImage: profile,
                    // backgroundColor: Colors.grey,
                    radius: 34,
                  ),
                SizedBox(width: 20), // مسافة بين الصورة الثانية والنص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        matchName,
                        style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        result,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        position,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      // إضافة نص تحت النصوص الحالية
                      SizedBox(height: 5), // مسافة بين النصوص
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ImageProvider _getImageProvider() {
  //   if (profile != null && profile!.isNotEmpty) {
  //     if (profile!.startsWith('http')) {
  //       return NetworkImage(profile!); // إذا كان الرابط من الإنترنت
  //     } else {
  //       return FileImage(File(profile!)); // إذا كان الرابط ملف محلي
  //     }
  //   } else {
  //     return AssetImage("image/basicicon.png"); // صورة افتراضية
  //   }
  // }

}
