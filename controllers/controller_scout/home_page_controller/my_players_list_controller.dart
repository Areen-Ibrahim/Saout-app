import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MyPlayersListController extends GetxController {

  Future<List<Map<String, dynamic>>> fetchPlayerData(List<String> ids) async {
    try {
      // جلب بيانات اللاعبين بناءً على قائمة المعرفات
      final playersSnapshot = await Future.wait(
        ids.map((id) => FirebaseFirestore.instance.collection('players').doc(id).get()).toList(),
      );

      // استخراج البيانات من المستندات التي تم جلبها
      List<Map<String, dynamic>> playersData = playersSnapshot
          .where((doc) => doc.exists) // التأكد من أن المستند موجود
          .map((doc) => doc.data() as Map<String, dynamic>) // تحويل البيانات إلى خريطة
          .toList();

      return playersData; // إرجاع قائمة اللاعبين
    } catch (e) {
      print('Error fetching players: $e');
      return []; // إرجاع قائمة فارغة في حال وجود خطأ
    }
  }

}
