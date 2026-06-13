import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetMatchController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var teamName = ''.obs;
  var teamImage = ''.obs;

  void setTeamName(String name) {
    teamName.value = name;
  }
  void setTeamImage(String image) {
    teamImage.value = image;
  }

  Future<Map<String, dynamic>?> getTeamDetails(String teamID) async {
    try {
      DocumentSnapshot teamSnapshot = await _firestore.collection('team').doc(teamID).get();
      if (teamSnapshot.exists) {
        return teamSnapshot.data() as Map<String, dynamic>?;
      } else {
        print('Team not found for teamID: $teamID');
        return null;
      }
    } catch (e) {
      print('Error fetching team details: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMatchesByDate(DateTime selectedDate) async {
    try {
      // ضبط بداية ونهاية اليوم بناءً على التاريخ المدخل
      DateTime startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
      DateTime endDate = startDate.add(Duration(days: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('matchDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('matchDate', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('matchDate')
          .get();

      List<Map<String, dynamic>> matches = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;

        // جلب بيانات الفريق الخاص بالمباراة بناءً على teamID
        if (matchData.containsKey('teamID')) {
          String teamID = matchData['teamID'];
          Map<String, dynamic>? teamData = await getTeamDetails(teamID);

          matchData['teamName'] = teamData?['teamName'] ?? 'Unknown Team';
          matchData['image'] = teamData?['image'] ?? ''; // صورة الفريق

          // إذا كان اسم الفريق المنافس موجودًا في جدول المباراة، جلب بياناته
          if (matchData.containsKey('opponentTeamName')) {
            String opponentTeamName = matchData['opponentTeamName'];
            Map<String, dynamic>? opponentTeamData = await getOpponentTeamDetails(opponentTeamName);

            matchData['opponentTeamName'] = opponentTeamData?['teamName'] ?? 'Unknown Opponent';
            matchData['opponentTeamImage'] = opponentTeamData?['image'] ?? ''; // صورة الفريق المنافس
          }
        }

        matches.add(matchData);
      }

      return matches;
    } catch (e) {
      print('Error in getMatchesByDate: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getOpponentTeamDetails(String opponentTeamName) async {
    try {
      // جلب بيانات الفريق المنافس من Firebase
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('team')
          .where('teamName', isEqualTo: opponentTeamName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // إذا تم العثور على الفريق المنافس، إرجاع بياناته
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        // إذا لم يتم العثور على الفريق المنافس، إرجاع null
        return null;
      }
    } catch (e) {
      print("Error fetching opponent team details: $e");
      return null;
    }
  }

}