import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChartPlayerController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchPlayerWithTeammates(String selectedPlayerId) async {
    try {
      // جلب بيانات اللاعب المختار
      DocumentSnapshot playerSnapshot = await firestore
          .collection('players')
          .doc(selectedPlayerId)
          .get();

      if (!playerSnapshot.exists) {
        throw Exception('Player not found');
      }

      Map<String, dynamic> selectedPlayerData = playerSnapshot.data() as Map<String, dynamic>;
      String teamId = selectedPlayerData['teamId'];

      // جلب بيانات الفريق الذي ينتمي إليه اللاعب
      DocumentSnapshot teamSnapshot = await firestore
          .collection('team')
          .doc(teamId)
          .get();

      if (!teamSnapshot.exists) {
        throw Exception('Team not found');
      }

      // جلب معرفات اللاعبين في الفريق مع استثناء اللاعب المختار
      List<dynamic> playersIds = teamSnapshot['playersId']
          .where((id) => id != selectedPlayerId)
          .toList();

      // جلب بيانات باقي اللاعبين في الفريق
      QuerySnapshot playersSnapshot = await firestore
          .collection('players')
          .where(FieldPath.documentId, whereIn: playersIds)
          .get();

      // تحويل اللاعبين إلى قائمة
      List<Map<String, dynamic>> teammates = playersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // إضافة بيانات اللاعب المختار كأول عنصر في القائمة مع علامة خاصة
      teammates.insert(0, {...selectedPlayerData, 'isSelected': true});

      return teammates;
    } catch (e) {
      print('Error fetching player and teammates: $e');
      return [];
    }
  }
}
