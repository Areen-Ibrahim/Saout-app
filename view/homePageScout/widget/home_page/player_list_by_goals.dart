import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayListInfoByGoals extends StatelessWidget {
  final String name;
  final String age;
  // final String teamName;
  final String position;
  final String? profile;
  final void Function() onTap;



  PlayListInfoByGoals({
    super.key,
    required this.name,
    required this.age,
    required this.position,
    required this.profile,
    required this.onTap,

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
                  backgroundImage: _getImageProvider(),
                  radius: 34,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        age,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        position,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

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

  ImageProvider _getImageProvider() {
    if (profile != null && profile!.isNotEmpty) {
      if (profile!.startsWith('http')) {
        return NetworkImage(profile!);
      } else {
        return FileImage(File(profile!));
      }
    } else {
      return AssetImage("image/basicicon.png");
    }
  }
}
