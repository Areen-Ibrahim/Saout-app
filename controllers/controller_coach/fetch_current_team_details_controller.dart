import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FetchCurrentTeamDetailsController extends GetxController{
  Future<Map<String, String>> fetchCurrentTeamDetails(String teamID) async {
    try {
      // جلب بيانات الفريق الحالي من قاعدة البيانات
      var teamDoc = await FirebaseFirestore.instance.collection('team').doc(teamID).get();

      if (teamDoc.exists) {
        var teamData = teamDoc.data() as Map<String, dynamic>;

        // إرجاع الاسم والصورة كـ Map
        return {
          'teamName': teamData['teamName'] ?? 'Unknown Team',  // اسم الفريق
          'image': teamData['image'] ?? '',  // صورة الفريق (إذا كانت موجودة)
        };
      } else {
        return {
          'teamName': 'Unknown Team',  // إذا لم يكن الفريق موجود
          'image': '',  // إذا لم توجد صورة
        };
      }
    } catch (e) {
      print('Error fetching team details: $e');
      return {
        'teamName': 'Unknown Team',
        'image': '',  // قيمة فارغة في حال حدوث خطأ
      };
    }
  }



}