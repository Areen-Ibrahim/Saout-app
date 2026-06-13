import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/routes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_picker/image_picker.dart';

class UpdateUserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final UserController userController = Get.find();

  // TextEditingControllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  XFile? pickedImage; // لتخزين الصورة المختارة

  var isLoading = false.obs;
  RxString profilePictureUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // جلب بيانات المستخدم عند بدء تشغيل الكونترولر
  }

  // دالة لتحميل بيانات المستخدم
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userController.currentUserUid.value).get();
      if (userDoc.exists) {
        firstNameController.text = userDoc['firstName'] ?? '';
        lastNameController.text = userDoc['lastName'] ?? '';
        phoneNumberController.text = userDoc['phoneNumber'] ?? '';
        profilePictureUrl.value = userDoc['profilePicture'] ?? ''; // جلب رابط الصورة
        print('User Data: ${userDoc.data()}');
      } else {
        print('User does not exist.');
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // دالة لاختيار صورة جديدة
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      await uploadImageToStorage();
    }
  }

  // دالة لرفع الصورة إلى Firebase Storage
  Future<void> uploadImageToStorage() async {
    if (pickedImage == null) return;

    try {
      // تحديد المسار داخل Firebase Storage
      String fileName = "profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = _firebaseStorage
          .ref()
          .child('Users')
          .child(userController.currentUserUid.value)
          .child(fileName);

      // رفع الصورة
      UploadTask uploadTask = storageRef.putFile(File(pickedImage!.path));
      TaskSnapshot snapshot = await uploadTask;

      // جلب الرابط بعد الرفع
      String downloadUrl = await snapshot.ref.getDownloadURL();
      profilePictureUrl.value = downloadUrl;
      print('Profile picture uploaded: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
      Get.snackbar('Error', 'Failed to upload image.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // دالة لتحديث بيانات المستخدم
  Future<void> updateUser(String userId) async {
    isLoading.value = true;
    try {
      // تحديث البيانات في Firestore
      await _firestore.collection('Users').doc(userId).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phoneNumber': phoneNumberController.text,
        'profilePicture': profilePictureUrl.value, // تحديث رابط الصورة
      });

      Get.snackbar('Success', 'User profile updated successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);

      // تحديث البيانات في الواجهة
      userController.firstName.value = firstNameController.text;
    } catch (e) {
      print('Error updating user: $e');
      Get.snackbar('Error', 'Failed to update user profile.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
