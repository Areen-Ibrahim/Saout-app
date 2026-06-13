import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PlayerListByGoalsController extends GetxController{
  Future<List<Map<String, dynamic>>> getPlayersSortedByGoals() async {
    try {
      // استعلام لجلب اللاعبين من جدول اللاعبين وترتيبهم حسب عدد الأهداف
      QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
          .collection('players') // اسم المجموعة في Firestore
          .orderBy('goals', descending: true) // ترتيب اللاعبين حسب عدد الأهداف من الأكبر إلى الأصغر
          .get();

      // تحويل البيانات إلى قائمة من الـ Map
      List<Map<String, dynamic>> playersData = playerSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // إرجاع البيانات المرتبة
      return playersData;
    } catch (e) {
      // في حالة حدوث خطأ في الاستعلام
      print("Error fetching players: $e");
      return [];
    }
  }

}