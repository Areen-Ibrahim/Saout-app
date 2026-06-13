import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetUpcomingMatchesController extends GetxController {
  Future<List<List<Map<String, dynamic>>>> getUpcomingMatches(List<String> teamIds) async {
    try {
      // جلب البيانات الخاصة بالفرق
      List<DocumentSnapshot> teams = await Future.wait(
        teamIds.map((id) => FirebaseFirestore.instance.collection('team').doc(id).get()).toList(),
      );

      List<Map<String, dynamic>> teamsData = teams
          .where((doc) => doc.exists)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // جلب المباريات القادمة فقط
      List<List<Map<String, dynamic>>> allUpcomingMatches = await Future.wait(
        teamsData.map((team) async {
          var querySnapshot = await FirebaseFirestore.instance
              .collection('matches')
              .where('teamID', isEqualTo: team['teamId'])
              .where('matchDate', isGreaterThanOrEqualTo: Timestamp.now()) // جلب المباريات المستقبلية فقط
              .orderBy('matchDate', descending: false) // ترتيب المباريات حسب التاريخ
              .limit(3)
              .get();

          List<Map<String, dynamic>> matches = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // دمج بيانات الفريق مع كل مباراة
          return matches.map((match) {
            match['teamName'] = team['teamName'];
            match['teamImage'] = team['image'];
            return match;
          }).toList();
        }).toList(),
      );

      return allUpcomingMatches;
    } catch (e) {
      print('Error fetching upcoming matches: $e');
      return [];
    }
  }
}
