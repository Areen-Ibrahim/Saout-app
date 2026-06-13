import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PlayerTwoGoalsController extends GetxController {
  Future<List<Map<String, dynamic>>> fetchPlayerData(List<String> ids) async {
    // جلب بيانات اللاعبين باستخدام المعرفات المعطاة
    final playersSnapshot = await Future.wait(
      ids.map((id) => FirebaseFirestore.instance.collection('players').doc(id).get()).toList(),
    );

    // تحويل البيانات إلى قائمة وإزالة اللاعبين غير الموجودين
    List<Map<String, dynamic>> playersData = playersSnapshot
        .where((doc) => doc.exists)
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // ترتيب اللاعبين حسب عدد الأهداف بشكل تنازلي وأخذ أعلى لاعبين
    playersData.sort((a, b) => (b['goals'] ?? 0).compareTo(a['goals'] ?? 0));
    return playersData.take(2).toList();
  }

  // دالة لجلب بيانات الفريق باستخدام معرف الفريق `teamId`
  Future<String> fetchTeamData(String teamId) async {
    final teamSnapshot = await FirebaseFirestore.instance.collection('team').doc(teamId).get();
    final teamData = teamSnapshot.data() as Map<String, dynamic>?;
    return teamData?['image'] ?? ''; // صورة الفريق
  }
}
