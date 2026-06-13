import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/date.dart';

class CardWidgetMatch extends StatelessWidget {
  final String title;
  final String matchStr;
  final String date;
  final String? imageOne;
  final String? imageTwo;

  const CardWidgetMatch({
    super.key,
    required this.matchStr,
    required this.date,
    required this.imageOne,
    required this.title,
    required this.imageTwo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // الصور بجانب بعضها
              CircleAvatar(
                backgroundImage: _getImageProvider(imageOne),
                radius: 20,
              ),
              const SizedBox(width: 5), // مسافة بين الصور
              CircleAvatar(
                backgroundImage: _getImageProvider(imageTwo),
                radius: 20,
              ),
              const SizedBox(width: 20), // مسافة بين الصور والنص
              // النص بجانب الصور
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      matchStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatDateTime(date),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_circle_right, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
  // دالة لتحميل الصورة بناءً على الرابط أو المسار
  ImageProvider<Object> _getImageProvider(String? image) {
    if (image != null && image.isNotEmpty) {
      if (image.startsWith('http')) {
        // تحميل الصورة من الإنترنت
        return NetworkImage(image);
      } else if (image.startsWith('/data/')) {
        // تحميل الصورة من مسار محلي باستخدام FileImage
        return FileImage(File(image));
      } else {
        // تحميل الصورة من الملفات المحلية (مثل الصور في assets)
        return AssetImage(image);
      }
    } else {
      // صورة افتراضية
      return const AssetImage("image/basicicon.png");
    }
  }

}


