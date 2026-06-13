import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../controllers/controller_scout/controller_scout_auth/reset_password_controller.dart';

class EnterNewPassword extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final CoachController _coachController = Get.find<CoachController>(); // الحصول على الكائن من GetX

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تحديث كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // حقل كلمة المرور الجديدة
            TextField(
              controller: newPasswordController,
              obscureText: true, // لإخفاء كلمة المرور
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'كلمة المرور الجديدة',
                hintText: 'أدخل كلمة المرور الجديدة',
              ),
            ),
            SizedBox(height: 16), // مسافة بين الحقول
            // حقل تأكيد كلمة المرور
            TextField(
              controller: confirmPasswordController,
              obscureText: true, // لإخفاء كلمة المرور
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'تأكيد كلمة المرور',
                hintText: 'أعد إدخال كلمة المرور الجديدة',
              ),
            ),
            SizedBox(height: 20), // مسافة إضافية
            ElevatedButton(
              onPressed: () async {
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                // تحقق من تطابق كلمات المرور
                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  Get.snackbar('خطأ', 'يرجى إدخال جميع الحقول.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                } else if (newPassword != confirmPassword) {
                  Get.snackbar('خطأ', 'كلمات المرور غير متطابقة.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                } else if (newPassword.length < 8) { // تحقق من طول كلمة المرور
                  Get.snackbar('خطأ', 'يجب أن تكون كلمة المرور أكثر من 8 أحرف.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                } else {
                  // استدعاء دالة تحديث كلمة المرور
                  await _coachController.updatePassword(newPassword);
                }
              },
              child: Text('تحديث كلمة المرور'),
            ),
          ],
        ),
      ),
    );
  }
}
