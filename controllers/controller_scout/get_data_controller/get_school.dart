import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetSchoolController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllTeamsInfoSchool() async {
    try {
      // استعلام لجلب جميع الفرق
      QuerySnapshot teamsSnapshot = await _firestore.collection('team').get();

      // إنشاء قائمة لتخزين بيانات الفرق
      List<Map<String, dynamic>> teamsList = [];

      // التجول عبر جميع الوثائق في مجموعة الفرق
      for (var doc in teamsSnapshot.docs) {
        // استخراج نوع الفريق
        String teamType = doc['teamType'];

        // التأكد من أن نوع الفريق لا يساوي "School Team"
        if (teamType == 'School Team') {
          // استخراج البيانات المطلوبة من وثيقة الفريق
          Map<String, dynamic> teamData = doc.data() as Map<String, dynamic>;

          // بناء خريطة جديدة تحتوي على البيانات المطلوبة
          teamsList.add({
            'teamId' : teamData['teamId'],
            'teamName': teamData['teamName'] ?? 'Unknown team name',
            'image': teamData['image'] ?? 'non image',
            'teamType': teamData['teamType'] ?? '',
            'numberOfWins': teamData['numberOfWins'] ?? 0,
            'averageAgeOfPlayers': teamData['averageAgeOfPlayers'] ?? 0,
          });
        }
      }

      return teamsList; // إعادة القائمة الكاملة بالفرق
    } catch (e) {
      print('Error fetching teams info: $e');
      return []; // إعادة قائمة فارغة في حال حدوث خطأ
    }
  }
}