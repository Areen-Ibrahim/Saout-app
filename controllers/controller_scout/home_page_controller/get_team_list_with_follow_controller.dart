import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetTeamListWithFollowController extends GetxController{
  Future<List<Map<String, dynamic>>> getTeamsWithMatches(List<String> teamIds) async {
    try {
      // جلب البيانات الخاصة بالفرق
      List<DocumentSnapshot> teams = await Future.wait(
        teamIds.map((id) => FirebaseFirestore.instance.collection('team').doc(id).get()).toList(),
      );

      // تحويل البيانات الخاصة بالفرق إلى قائمة من الـ Maps
      List<Map<String, dynamic>> teamsData = teams
          .where((doc) => doc.exists)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // جلب المباريات الخاصة بكل فريق
      List<QuerySnapshot> matchSnapshots = await Future.wait(
        teamsData.map((team) {
          return FirebaseFirestore.instance
              .collection('matches')
              .where('teamID', isEqualTo: team['teamId'])
              .where('matchDate', isLessThan: Timestamp.now()) // المباريات السابقة فقط
              .get();
        }).toList(),
      );

      // جمع جميع المباريات في قائمة واحدة ودمج بيانات الفريق مع كل مباراة
      List<Map<String, dynamic>> allMatches = matchSnapshots
          .expand((querySnapshot) => querySnapshot.docs)
          .where((doc) => doc.exists)
          .map((doc) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;

        // جلب بيانات الفريق بناءً على teamID المرتبط بكل مباراة
        Map<String, dynamic> team = teamsData.firstWhere(
              (teamData) => teamData['teamId'] == matchData['teamID'],
          orElse: () => {},
        );

        // دمج بيانات الفريق مع المباراة
        matchData['teamName'] = team['teamName'];
        matchData['image'] = team['image'];

        // إذا كان الفريق المنافس موجودًا أيضًا في البيانات
        matchData['opponentName'] = matchData['opponentTeamName']; // تأكد من أن هذه الحقول موجودة في بيانات المباراة
        matchData['opponentImage'] = matchData['opponentTeamImage']; // جلب صورة الفريق المنافس

        return matchData;
      }).toList();


      // فرز المباريات حسب التاريخ من الأحدث إلى الأقدم
      allMatches.sort((a, b) => (b['matchDate'] as Timestamp).compareTo(a['matchDate'] as Timestamp));

      return allMatches.isNotEmpty ? allMatches : [];
    } catch (e) {
      print('Error fetching teams or matches: $e');
      return [];
    }
  }
}
