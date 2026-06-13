import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'sign_up_coach_controller.dart';  // تأكد من المسار الصحيح
import 'team_controller.dart';  // تأكد من المسار الصحيح

class UpdateProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CoachController _coachController = Get.find();
  final TeamController _teamController = Get.find();

  // TextEditingControllers
  TextEditingController userNameController = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController teamNameController = TextEditingController();
  TextEditingController teamLocationController = TextEditingController();
  TextEditingController teamDescriptionController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  final List<String> teamTypeOptions = [
    'Academy Level A',
    'Academy Level B',
    'Academy Level C',
    'School Team',
  ];
  var isLoading = false.obs; // متغير حالة التحميل


  // خصائص الصورة ونوع الفريق
  File? pickedImage; // الصورة التي تم اختيارها
  String imageUrl = ''; // رابط الصورة في Firebase
  Rx<File?> profileImage = Rx<File?>(null);
  final selectedTeamType = ''.obs;

  final ImagePicker _picker = ImagePicker(); // أداة اختيار الصور

  // دالة لاختيار الصورة
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      print('Image picked: ${profileImage.value?.path}'); // إضافة هذه الطباعة
      update();
    } else {
      print('No image selected.');
    }
  }


  // دالة لتحميل الصورة إلى Firebase Storage
  Future<String> uploadImage() async {
    if (profileImage.value == null) {
      print('No image selected.'); // طباعة رسالة عند عدم اختيار صورة
      return ''; // إذا لم يتم اختيار صورة
    }
    try {
      String fileName = 'teams/${_teamController.teamId.value}.png'; // تعيين اسم الملف بناءً على معرف الفريق
      await _storage.ref(fileName).putFile(profileImage.value!); // استخدام profileImage
      String downloadURL = await _storage.ref(fileName).getDownloadURL();
      return downloadURL; // إرجاع رابط الصورة المحملة
    } catch (e) {
      print('Error uploading image: $e');
      throw 'Failed to upload image';
    }
  }

  // دالة لاسترجاع بيانات المدرب
  Future<void> fetchCoachData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Coaches')
          .doc(_coachController.coachId.value)
          .get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        userNameController.text = data['userName'];
        // emailController.text = data['email'];
        phoneNumberController.text = data['phoneNumber'];
        // imageUrl = data['imageUrl']; // جلب رابط الصورة
        update(); // تحديث واجهة المستخدم
      }
    } catch (e) {
      print('Error fetching coach data: $e');
    }
  }

  // دالة لاسترجاع بيانات الفريق
  Future<void> fetchTeamData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('team')
          .doc(_teamController.teamId.value)
          .get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        teamNameController.text = data['teamName'] ?? '';
        teamLocationController.text = data['location'] ?? '';
        teamDescriptionController.text = data['description'] ?? '';

        print("temaname $teamNameController" );
        print("temaname $selectedTeamType" );

        // تأكد من أن القيمة المحفوظة موجودة في القائمة
        String teamType = data['teamType'] ?? '';
        print("Fetched team type: $teamType");

        if (teamTypeOptions.contains(teamType)) {
          selectedTeamType.value = teamType; // تعيين القيمة
        } else {
          selectedTeamType.value = teamTypeOptions[0]; // تعيين قيمة افتراضية إذا لم تكن موجودة
        }

        imageUrl = data['image'] ?? '';
        profileImage.value = null;
        update(); // تحديث واجهة المستخدم
      }
    } catch (e) {
      print('Error fetching team data: $e');
    }
  }




  // دالة لتحديث بيانات المدرب
  Future<void> updateCoach() async {
    try {
      // تحميل الصورة إذا كانت جديدة
      String uploadedImageUrl = await uploadImage();
      await _firestore.collection('Coaches').doc(_coachController.coachId.value).update({
        'userName': userNameController.text,
        // 'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        if (uploadedImageUrl.isNotEmpty) 'imageUrl': uploadedImageUrl, // تحديث الرابط إذا كان موجودًا
      });
    } catch (e) {
      print('Error updating coach: $e');
      throw 'Failed to update coach profile';
    }
  }

  // دالة لتحديث بيانات الفريق
  Future<void> updateTeam() async {
    try {

      String uploadedImageUrl = await uploadImage(); // تحميل الصورة إذا كانت جديدة
      await _firestore.collection('team').doc(_teamController.teamId.value).update({
        'teamName': teamNameController.text,
        'location': teamLocationController.text,
        'description': teamDescriptionController.text,
        'teamType': selectedTeamType.value,
        'latitude': latitudeController.text,
        'longitude': longitudeController.text,
        if (uploadedImageUrl.isNotEmpty) 'image': uploadedImageUrl, // تحديث الصورة إذا كانت موجودة
      });
    } catch (e) {
      print('Error updating team: $e');
      throw 'Failed to update team profile';
    }
  }

  // دالة لتحديث بيانات المدرب والفريق معًا وإظهار رسالة واحدة فقط
  Future<void> updateCoachAndTeam() async {
    isLoading.value = true;
    try {
      // String newEmail = emailController.text;
      String newPhoneNumber = phoneNumberController.text;
      String currentEmail = _coachController.coachEmail.value;
      String currentPhoneNumber = _coachController.coachPhone.value;

      // إذا تم تغيير البريد الإلكتروني
      // if (newEmail != currentEmail) {
      //   if (await isEmailExists(newEmail)) {
      //     Get.snackbar('Error', 'Email already exists.',
      //         backgroundColor: Colors.red, colorText: Colors.white);
      //     return; // إذا كان البريد الإلكتروني موجودًا، لا تكمل العملية
      //   }
      // }

      // إذا تم تغيير رقم الهاتف
      if (newPhoneNumber != currentPhoneNumber) {
        if (await isPhoneNumberExists(newPhoneNumber)) {
          Get.snackbar('Error', 'Phone number already exists.',
              backgroundColor: Colors.red, colorText: Colors.white);
          return; // إذا كان رقم الهاتف موجودًا، لا تكمل العملية
        }
      }
      await updateCoach();  // تحديث بيانات المدرب
      await updateTeam();   // تحديث بيانات الفريق

      // إظهار رسالة نجاح واحدة بعد نجاح العمليتين
      Get.snackbar('Success', 'Profile updated successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white
      );
    } catch (e) {
      // في حالة حدوث خطأ أثناء التحديث
      Get.snackbar('Error', 'Profile not updated successfully.',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print(e);
    }finally {
      isLoading.value = false; // إنهاء حالة التحميل
    }

  }
  Future<bool> isEmailExists(String email) async {
    var querySnapshot = await _firestore
        .collection('Coaches')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty; // إذا كانت هناك مستندات، فإن البريد الإلكتروني موجود
  }

  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    var querySnapshot = await _firestore
        .collection('Coaches')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    return querySnapshot.docs.isNotEmpty; // إذا كانت هناك مستندات، فإن رقم الهاتف موجود
  }



}
