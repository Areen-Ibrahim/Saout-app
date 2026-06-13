import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';  // لقراءة الأصول
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/color.dart';  // للوصول إلى مسارات التخزين المحلي

class ProfilePictureWidget extends StatelessWidget {
  final Function pickImage;  // دالة لاختيار صورة
  final Rx<File?> image;  // صورة المستخدم كـ Rx<File?>
  final String? defaultProfilePicture;  // مسار الصورة الافتراضية

  const ProfilePictureWidget({
    Key? key,
    required this.pickImage,
    required this.image, // الصورة الممررة كـ Rx<File?>
    this.defaultProfilePicture, // الصورة الافتراضية
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          await pickImage();
        },
        child: Obx(() {
          return Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(color: ColorApp.yellow, width: 2),
              shape: BoxShape.circle
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: image.value != null ? FileImage(image.value!) : null,
              child: image.value == null
                  ? Icon(Icons.camera_alt, size: 35)  // عرض أيقونة الكاميرا عند غياب الصورة
                  : null,
            ),
          );
        }),
      ),
    );
  }

}
