import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeController extends GetxController {
  var firstName = ''.obs; // متغير قابل للملاحظة لاسم المستخدم
  var profilePicture = ''.obs; // متغير قابل للملاحظة لصورة المستخدم

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // جلب بيانات المستخدم عند بدء تشغيل الكونترولر
  }

  void fetchUserData() async {
    try {
      User? user = _auth.currentUser; // الحصول على المستخدم الحالي
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          firstName.value = userDoc['firstName'] ?? 'User'; // تعيين الاسم الأول
          profilePicture.value = userDoc['profilePicture'] ?? ''; // تعيين الصورة الشخصية
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
}
