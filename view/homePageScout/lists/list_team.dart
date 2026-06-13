import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saoutapp/core/color.dart';

class ListTeam extends StatelessWidget {
  final String name;
  final String age;
  final String position;
  final String? profile;
  final void Function() onTap;
  final void Function() iconButton; // استخدام ValueNotifier
  final IconData icon;
  final Color color;
  final bool isLoading;


  ListTeam({
    super.key,
    required this.name,
    required this.age,
    required this.position,
    required this.profile,
    required this.onTap,
    required this.iconButton,
    required this.icon,
    required this.color,
    required this.isLoading,
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
                  radius: 23,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(color: ColorApp.background, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'play'),
                      ),
                      SizedBox(height: 5),
                      Text(
                        age,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                isLoading
                    ? SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2.5,
                  ),
                )
                    : IconButton(
                  onPressed: iconButton,
                  icon: Icon(
                    icon,
                    color: color,
                    size: 23,
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
