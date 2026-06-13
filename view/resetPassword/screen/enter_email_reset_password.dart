import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../core/color.dart';

class EnterEmailResetPassword extends StatelessWidget {
  final CoachController coachController = Get.put(CoachController());
  final TextEditingController emailController = TextEditingController();
  // متغير لتخزين رسالة الخطأ
  String errorMessage = '';

  // دالة لإعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'A password reset link has been sent to your email.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (error) {
      errorMessage = 'Failed to send password reset email: ${error.toString()}';
      Get.snackbar('Error', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.blue,
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white), // تغيير لون النص إلى الأبيض
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(color: Colors.white), // تغيير لون تسمية الحقل
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // لون الحدود عند التفعيل
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // لون الحدود عند التركيز
                  ),
                ),
              ),
              // عرض رسالة الخطأ تحت حقل الإدخال
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              Obx(() => coachController.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  String email = emailController.text.trim();
                  if (email.isEmpty) {
                    errorMessage = 'Please enter an email address';
                    return;
                  }

                  bool exists = await coachController.checkEmailExists(email);
                  if (exists) {
                    errorMessage = 'Email already exists.';
                  } else {
                    errorMessage = ''; // إعادة تعيين رسالة الخطأ
                    await resetPassword(email);
                  }
                  // تحديث واجهة المستخدم
                  (context as Element).markNeedsBuild(); // لإعادة بناء واجهة المستخدم
                },
                child: Text('Verify Email'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
