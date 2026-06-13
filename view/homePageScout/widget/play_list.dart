import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayListInfo extends StatelessWidget {
  final String name;
  final String age;
  final String teamName;
  final String position;
  final String? profile;
  final void Function() onTap;
  final bool? isFollowing;
  final void Function() onFollow;
  final IconData icon;
  final Color color;
  final bool isLoading;


  PlayListInfo({
    super.key,
    required this.name,
    required this.age,
    required this.position,
    required this.profile,
    required this.onTap,
     this.isFollowing,
    required this.onFollow,
    required this.teamName,
    required this.icon,
    required this.color,
    required this.isLoading
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
                      Text(
                        teamName,
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
                  onPressed: onFollow,
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
