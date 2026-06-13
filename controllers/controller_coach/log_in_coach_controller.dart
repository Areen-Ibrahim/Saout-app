import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';

import '../../routes.dart';
import '../../view/login/loginCoachScreen/screen/log_in_coach.dart';

class LogInCoachController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  CoachController controller = Get.put(CoachController());

  var isLoading = false.obs;
  var userType = ''.obs;


// إضافة المتغيرات لتخزين المعرفات
  String coachId = '';
  String teamId = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    emailController.clear();
    passwordController.clear();
    super.onInit();
  }
  @override
  void onClose() {
// تحرير المتحكمات
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      isLoading(true); // تشغيل مؤشر التحميل
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
// الحصول على معرف المدرب
          coachId = userCredential.user!.uid;

// جلب معرف الفريق من قاعدة البيانات باستخدام معرف المدرب
          QuerySnapshot teamSnapshot = await _firestore
              .collection('team')
              .where('coachId', isEqualTo: coachId)
              .get();

          if (teamSnapshot.docs.isNotEmpty) {
            teamId = teamSnapshot.docs.first.id;  // الحصول على معرف الفريق

// تمرير معرفات المدرب والفريق إلى الصفحة التالية
            Get.offNamed(AppRoutes.homePage, arguments: {
              'coachId': coachId,
              'teamId': teamId,
            });

            print("${coachId} lllllllllllllllllllllllllllllllllll");
            print("${teamId} lllllllllllllllllllllllllllllllllll");
            controller.updateTokenInFirestore(coachId);
            Get.snackbar(
              'Success', 'Logged in successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }}
      } catch (e) {
        Get.snackbar('Error', 'email or password is not correct',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(e);
      } finally {
        isLoading(false); // إيقاف مؤشر التحميل
      }
    } else {
      Get.snackbar('Error', 'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  Future<bool> isEmailRegistered(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // البحث في Firestore باستخدام البريد الإلكتروني
      final querySnapshot = await firestore
          .collection('Coaches') // اسم مجموعة المستخدمين
          .where('email', isEqualTo: email)
          .get();

      // إذا كانت النتيجة تحتوي على مستندات، فهذا يعني أن البريد الإلكتروني موجود
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false; // خطأ أثناء التحقق
    }
  }
  Future<void> updatePasswordInFirestore(String newPassword, String email) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      // البحث عن المستخدم في Firestore
      final querySnapshot = await _firestore
          .collection('Coaches')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id; // الحصول على معرف المستند
        final oldPassword = querySnapshot.docs.first.get('password');

        // التحقق من أن المستخدم الحالي متطابق
        User? user = _auth.currentUser;

        if (user == null || user.email != email) {
          // إعادة تسجيل الدخول
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: oldPassword,
          );
          user = _auth.currentUser;
        }

        // تحديث كلمة المرور في FirebaseAuth
        if (user != null) {
          await user.updatePassword(newPassword);

          // تحديث كلمة المرور في Firestore
          await _firestore.collection('Users').doc(docId).update({
            'password': newPassword,
          });

          // تسجيل خروج ثم تسجيل الدخول للتحقق
          await _auth.signOut();
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: newPassword,
          );

          Get.snackbar(
            "Success",
            "Password updated successfully in both Auth and Firestore.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.to(() => LoginCoachScreen());
        } else {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Failed to locate the current user.',
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "No user found with this email.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Failed to update password: $e");
      Get.snackbar(
        "Error",
        "Failed to update password. Please try again later.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


}
