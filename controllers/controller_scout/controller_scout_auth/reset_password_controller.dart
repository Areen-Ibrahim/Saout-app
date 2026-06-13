import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // وظيفة لإعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Reset link sent to your email.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // وظيفة لجلب userId باستخدام البريد الإلكتروني
  Future<String?> getUserIdByEmail(String email) async {
    if (_auth.currentUser == null) {
      Get.snackbar('Error', 'User is not logged in.');
      return null; // المستخدم ليس مسجلاً دخولًا
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // إرجاع userId (معرف الوثيقة)
      } else {
        return null; // لا يوجد مستخدم
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }


  // وظيفة لتحديث كلمة المرور
  Future<void> updatePassword(String newPassword, String userId) async {
    try {
      // تحديث كلمة المرور في Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }

      // تحديث كلمة المرور في Firestore
      await _firestore.collection('Users').doc(userId).update({
        'password': newPassword, // تحديث كلمة المرور في قاعدة البيانات
      });

      Get.snackbar('Success', 'Password updated successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
