import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/model_coach/sign_up_model.dart';
import '../../routes.dart'; // تأكد من أن المسار صحيح

class CoachController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  var isLoading = false.obs; // حالة التحميل
  var coachId = ''.obs;
  var coachEmail = ''.obs; // متغير لتخزين البريد الإلكتروني
  var coachPhone = ''.obs;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  Future<String?> getFirebaseToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print("Error getting Firebase token: $e");
      return null;
    }
  }

  // دالة لتخزين التوكن في قاعدة البيانات عند تسجيل الدخول
  Future<void> updateTokenInFirestore(String coachId) async {
    try {
      String? token = await getFirebaseToken();
      if (token != null) {
        // استخدام set() مع الخيار merge: true لتحديث الحقل أو إنشائه في حال عدم وجوده
        await _firestore.collection('Coaches').doc(coachId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        print('Token updated successfully for coach: $coachId');
      }
    } catch (e) {
      print('Error updating token: $e');
    }
  }

  // التحقق من وجود البريد الإلكتروني في قاعدة البيانات
  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Coaches')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty; // إذا كان هناك مستندات، البريد الإلكتروني موجود
    } catch (e) {
      print("Error checking email: $e");
      return false;
    }
  }

  // التحقق من وجود رقم الهاتف في قاعدة البيانات
  Future<bool> checkPhoneExists(String phone) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Coaches')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      return querySnapshot.docs.isNotEmpty; // إذا كان هناك مستندات، رقم الهاتف موجود
    } catch (e) {
      print("Error checking phone: $e");
      return false;
    }
  }
  // دالة للتحقق من وجود البريد الإلكتروني ورقم الهاتف
  Future<Map<String, bool>> checkEmailAndPhoneExists(String email, String phone) async {
    bool emailExists = false;
    bool phoneExists = false;

    try {
      // التحقق من وجود البريد الإلكتروني
      QuerySnapshot emailSnapshot = await _firestore
          .collection('Coaches')
          .where('email', isEqualTo: email)
          .get();
      emailExists = emailSnapshot.docs.isNotEmpty;

      // التحقق من وجود رقم الهاتف
      QuerySnapshot phoneSnapshot = await _firestore
          .collection('Coaches')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      phoneExists = phoneSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email or phone: $e");
    }

    return {'emailExists': emailExists, 'phoneExists': phoneExists};
  }

  var emailError = ''.obs;
  var phoneError = ''.obs;

  Future<void> signUp() async {
    isLoading.value = true;
    emailError.value = '';  // إعادة تعيين الأخطاء
    phoneError.value = '';

    try {
      // التحقق من وجود البريد الإلكتروني ورقم الهاتف
      var result = await checkEmailAndPhoneExists(emailController.text, phoneController.text);

      if (result['emailExists']!) {
        print('Email already exists');
        Get.snackbar('Error', 'Email already exists',
        backgroundColor: Colors.red,
          colorText: Colors.white
        );

      }

      if (result['phoneExists']!) {
        print('Phone number already exists');
        Get.snackbar('Error', 'Phone number already exists',
        backgroundColor: Colors.red,
          colorText: Colors.white
        );
      }

      // إذا كان هناك أخطاء، لا تتابع عملية التسجيل
      if (emailError.value.isNotEmpty || phoneError.value.isNotEmpty) {
        return;
      }

      // إنشاء حساب جديد في Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // إعداد بيانات المدرب مع تعيين userType كـ "coach"
      Map<String, dynamic> coachData = {
        'userName': userNameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'password': passwordController.text.trim(),
        'userType': 'coach',
      };
      // حفظ بيانات المدرب في Firestore
      await _firestore.collection('Coaches').doc(userCredential.user?.uid).set(coachData);
      coachId.value = userCredential.user?.uid ?? '';
      updateTokenInFirestore(coachId.value);


      Get.toNamed(AppRoutes.createTeam);

    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // دالة للتحقق من صحة المدخلات (الحقول)
  String? validateField(String value, String fieldType, {String? password}) {
    if (value.contains(' ')) {
      return 'Spaces are not allowed.'; // تحقق من عدم وجود مسافات
    }

    switch (fieldType) {
      case 'userName':
        return value.isEmpty ? 'Please enter the user name' : null;
      case 'email':
        return !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)
            ? 'Please enter a valid email'
            : null;
      case 'phoneNumber':
        return !RegExp(r'^(?:\+966|05)[0-9]{8}$').hasMatch(value)
            ? 'Starting with 05 and must be 10 digits.'
            : null;
      case 'password':
        return value.length < 8
            ? 'Please enter a valid password, must be more than 8 characters'
            : null;
      case 'confirmPassword':
        if (value.isEmpty) {
          return 'Please confirm your password';
        } else if (value != password) {
          return 'Passwords do not match';
        }
        return null;
      default:
        return null; // إذا كان الحقل غير معروف
    }
  }

  // التحقق من جميع الحقول وبناء نموذج المدرب
  CoachModel? validateAndCreateCoach() {
    // التحقق من صحة جميع المدخلات
    if (validateField(userNameController.text, 'userName') != null ||
        validateField(emailController.text, 'email') != null ||
        validateField(phoneController.text, 'phoneNumber') != null ||
        validateField(passwordController.text, 'password') != null ||
        validateField(confirmPasswordController.text, 'confirmPassword', password: passwordController.text) != null) {
      return null; // إذا كان هناك خطأ
    }

    // بناء نموذج المدرب إذا كانت المدخلات صحيحة
    return CoachModel(
      userName: userNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      userType: 'coach',
      // fcmToken: '',
    );
  }

  Future<void> updateCoach(String coachId, CoachModel coach) async {
    isLoading.value = true;
    try {
      await _firestore.collection('Coaches').doc(coachId).update(coach.toMap());
      Get.snackbar('Success', 'Coach profile updated successfully.');
      Get.offNamed(AppRoutes.updateCoach); // استخدم toNamed() إذا كان `updateCoach` اسم الطريق
    } catch (e) {
      print('Error updating coach: $e');
      Get.snackbar('Error', 'Failed to update coach profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: "Confirm Logout",
      middleText: "Are you sure you want to log out?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.blueAccent,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          await _auth.signOut();
          Get.back(); // إغلاق الـ Dialog بعد التأكيد
          Get.snackbar(
            'Success',
            'Logged out successfully.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.chooseUser); // إعادة التوجيه إلى صفحة تسجيل الدخول
        } catch (e) {
          print('Error signing out: $e');
          Get.back(); // إغلاق الـ Dialog عند وجود خطأ
          Get.snackbar(
            'Error',
            'Failed to log out',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }


  var coachName = ''.obs;

  Future<void> fetchCoachData() async {
    try {
      // جلب بيانات المدرب باستخدام المعرف المخزن
      var coachData = await _firestore.collection('Coaches').doc(coachId.value).get();
      if (coachData.exists) {
        coachName.value = coachData['userName'] ?? 'Unknown'; // تعيين اسم المدرب
        coachEmail.value = coachData['email'] ?? ''; // تخزين البريد الإلكتروني
        coachPhone.value = coachData['phoneNumber'] ?? ''; // تخزين رقم الهاتف
      }
    } catch (e) {
      print('Error fetching coach data: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser; // الحصول على المستخدم الحالي
      if (user != null) {
        await user.updatePassword(newPassword); // تحديث كلمة المرور
        Get.snackbar('Success', 'Password updated successfully.',
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.offNamed(AppRoutes.chooseUser); // إعادة توجيه المستخدم إلى صفحة تسجيل الدخول
      } else {
        Get.snackbar('Error', 'No user logged in.',
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Error updating password: $e');
      Get.snackbar('Error', 'Failed to update password: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Check your email for a password reset link.',
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (error) {
      print('Failed to send password reset email: ${error.toString()}');
      Get.snackbar('Error', 'Failed to send password reset email: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
