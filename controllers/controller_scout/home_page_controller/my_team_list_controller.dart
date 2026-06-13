import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MyTeamListController extends GetxController {
  // جلب بيانات الفرق
  Future<List<Map<String, dynamic>>> fetchTeamsData(List<String> teamIds) async {
    final teamsSnapshot = await Future.wait(
      teamIds.map((id) => FirebaseFirestore.instance.collection('team').doc(id).get()).toList(),
    );

    List<Map<String, dynamic>> teamsData = teamsSnapshot
        .where((doc) => doc.exists)
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return teamsData;
  }
  Future<List<Map<String, dynamic>>> fetchUpcomingMatches(List<Map<String, dynamic>> teamsData) async {
    return Future.wait(
      teamsData.map((team) async {
        final matchesSnapshot = await FirebaseFirestore.instance
            .collection('matches')
            .where('teamID', isEqualTo: team['teamId'] as String) // تأكد من أن teamId هو String
            .where('matchDate', isGreaterThanOrEqualTo: Timestamp.now())
            .orderBy('matchDate')
            .limit(1)
            .get();

        if (matchesSnapshot.docs.isNotEmpty) {
          var matchData = matchesSnapshot.docs.first.data() as Map<String, dynamic>; // تحويل البيانات إلى Map<String, dynamic>
          matchData['matchDate'] = (matchData['matchDate'] as Timestamp).toDate();
          return matchData;
        }

        return <String, dynamic>{}; // إرجاع Map فارغ من النوع المطلوب
      }).toList(), // تأكد من أن map تُرجع قائمة
    );
  }

}
