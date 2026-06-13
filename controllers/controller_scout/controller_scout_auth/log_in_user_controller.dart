import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد Firebase Auth
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import '../../../view/homePageScout/screen/home_scout.dart';
import '../../../view/login/loginScout/screens/login_scout_screen.dart';

class LoginController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;
  var userType = ''.obs;
  var userId = ''.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController userController = Get.put(UserController());


  final FirebaseAuth _auth = FirebaseAuth
      .instance; // إنشاء مثيل من FirebaseAuth

  @override
  void onInit() {
    emailController.clear();
    passwordController.clear();
    getUserType();
    userController.saveFCMToken(userId.value);
    super.onInit();
  }

  @override
  void onClose() {
    // تحرير المتحكمات
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }


  // دالة لجلب نوع المستخدم
  Future<void> getUserType() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(
          user.uid).get();
      if (userDoc.exists) {
        userType.value = userDoc['user_type']; // تعيين نوع المستخدم
      }
    }
  }
  Future<String?> getUserIdByEmail(String email) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // البحث عن المستخدم بناءً على البريد الإلكتروني
      final querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // إذا تم العثور على البريد الإلكتروني، أعد معرف المستخدم
        return querySnapshot.docs.first.id;
      } else {
        // إذا لم يتم العثور على البريد الإلكتروني
        return null;
      }
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
  Future<bool> isEmailRegistered(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // البحث في Firestore باستخدام البريد الإلكتروني
      final querySnapshot = await firestore
          .collection('Users') // اسم مجموعة المستخدمين
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
          .collection('Users')
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
          Get.to(() => LoginScoutScreen());
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



  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      isLoading(true); // تشغيل مؤشر التحميل
      try {
        // محاولة تسجيل الدخول
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // إذا تم تسجيل الدخول بنجاح
        if (userCredential.user != null) {
          // جلب نوع المستخدم بعد تسجيل الدخول
          await getUserType();
          print('User UID after login: ${userCredential.user?.uid}');

          userId.value = userCredential.user!.uid; // تخزين معرف المستخدم
          print('User UID after login: ${userId.value}');
          userController.setupFCM();

          Get.snackbar(
            'Success',
            'Logged in successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // الانتقال إلى صفحة الترحيب
          Future.delayed(Duration(milliseconds: 100), () {
            Get.to(() => HomeScout(),
              arguments: {
                'userId': userId.value,
              },
              transition: Transition.zoom,
              duration: Duration(milliseconds: 670),
            );
          });
        }
      } catch (e) {
        // في حالة حدوث خطأ
        String errorMessage = 'Email or password is not correct';

        // التعامل مع أنواع الأخطاء المختلفة
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found for that email.';
            Get.snackbar('Error', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Wrong password provided.';
            Get.snackbar('Error', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
          } else if (e.code == 'invalid-email') {
            errorMessage = 'The email address is not valid.';
            Get.snackbar('Error', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
          }
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading(false); // إيقاف مؤشر التحميل
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}