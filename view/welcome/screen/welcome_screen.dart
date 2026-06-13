import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/routes.dart';
import 'dart:io'; // استيراد مكتبة File
import '../../../controllers/controller_scout/welcome_controller/welcome_controller.dart';
import '../../../core/color.dart';

class WelcomePage extends StatelessWidget {
  final WelcomeController welcomeController = Get.put(WelcomeController()); // إنشاء مثيل من الكونترولر

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('image/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => CircleAvatar(
                  backgroundImage: welcomeController.profilePicture.value.isNotEmpty
                      ? FileImage(File(welcomeController.profilePicture.value)) // استخدم FileImage لتحميل الصورة من المسار المحلي
                      : AssetImage("image/avatar.png") as ImageProvider, // صورة افتراضية
                  radius: 100,
                )),
                SizedBox(height: 12),
                Obx(() => Text(
                  "Welcome to Saout, ${welcomeController.firstName.value}!", // استخدام اسم المستخدم
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                    color: ColorApp.richLavender,
                  ),
                )),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(bottom: 10),
            child: TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.homePageScout);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Next", style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300
                  )),
                  Icon(Icons.arrow_right_alt, color: Colors.white, size: 29,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
