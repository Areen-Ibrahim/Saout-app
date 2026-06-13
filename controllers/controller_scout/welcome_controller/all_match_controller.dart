import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AllMatchesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDetailsMatch(String matchId) async {
    // جلب بيانات المباراة
    DocumentSnapshot<Map<String, dynamic>> matchSnapShot =
    await FirebaseFirestore.instance.collection('matches').doc(matchId).get();

    // التأكد من أن البيانات تم جلبها بنجاح
    if (!matchSnapShot.exists) {
      throw Exception("Match not found");
    }

    Map<String, dynamic> matchData = matchSnapShot.data()!;

    // جلب معرفات اللاعبين من المباراة
    List<dynamic> playerIds = matchData['playerIDs'] ?? [];

    // جلب معرف الفريق
    String teamID = matchData['teamID'] ?? '';

    // جلب قائمة الأهداف مع المعرفات والدقائق
    List<Map<String, dynamic>> goalsList = List<Map<String, dynamic>>.from(
        matchData['goalsList']?.map((goal) => {
          'minute': goal['minute'] ?? 1,
          'playerId': goal['playerId'] ?? '',
        }) ??
            []);

    // جمع جميع معرفات اللاعبين من playerIDs وgoalsList
    Set<String> allPlayerIds = Set<String>.from(playerIds);
    for (var goal in goalsList) {
      allPlayerIds.add(goal['playerId']);
    }

    // جلب تفاصيل اللاعبين بناءً على جميع المعرفات
    List<Map<String, dynamic>> playerDetails = [];
    for (String playerId in allPlayerIds) {
      DocumentSnapshot<Map<String, dynamic>> playerSnapshot =
      await FirebaseFirestore.instance.collection('players').doc(playerId).get();

      if (playerSnapshot.exists) {
        Map<String, dynamic>? playerData = playerSnapshot.data();
        playerDetails.add({
          'playerId': playerId,
          'firstName': playerData['firstName'] ?? 'Unknown',
          'lastName': playerData['lastName'] ?? 'Unknown',
          'image': playerData['image'] ?? '',
          'playerNumber': playerData['playerNumber'] ?? 0,
        });
            }
    }

    // جلب تفاصيل الفريق بناءً على teamID
    Map<String, dynamic>? teamData;
    if (teamID.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> teamSnapshot =
      await FirebaseFirestore.instance.collection('team').doc(teamID).get();

      if (teamSnapshot.exists) {
        teamData = teamSnapshot.data();
      } else {
        // معالجة الحالة إذا كان الفريق غير موجود
        teamData = {
          'image': '', // صورة افتراضية
          'teamName': 'Unknown Team', // اسم افتراضي
        };
      }
    } else {
      // إذا لم يكن teamID موجود، استخدم بيانات افتراضية
      teamData = {
        'image': '', // صورة افتراضية
        'teamName': 'Unknown Team', // اسم افتراضي
      };
    }

    // جلب تفاصيل الفريق المنافس إذا كان موجودًا
    Map<String, dynamic>? opponentTeamData;
    String opponentTeamName = matchData['opponentTeamName'] ?? '';
    if (opponentTeamName.isNotEmpty) {
      // البحث عن الفريق المنافس بناءً على الاسم
      QuerySnapshot<Map<String, dynamic>> opponentTeamSnapshot =
      await FirebaseFirestore.instance.collection('team')
          .where('teamName', isEqualTo: opponentTeamName)
          .limit(1)
          .get();

      if (opponentTeamSnapshot.docs.isNotEmpty) {
        opponentTeamData = opponentTeamSnapshot.docs.first.data();
      }
    }

    // صورة الفريق المنافس إذا كانت موجودة
    String opponentTeamImage = opponentTeamData?['image'] ?? '';

    // إضافة خطوط العرض والطول
    double latitude = matchData['latitude'] ?? 0.0;
    double longitude = matchData['longitude'] ?? 0.0;

    // جلب قائمة المساعدين
    List<String> assisters = List<String>.from(matchData['assisters'] ?? []);

    // إرجاع بيانات المباراة مع تفاصيل اللاعبين وتفاصيل الفريق والفريق المنافس
    return {
      'opponentTeamName': matchData['opponentTeamName'] ?? '',
      'matchLocation': matchData['matchLocation'] ?? '',
      'matchDate': matchData['matchDate'] ?? '',
      'matchFormation': matchData['matchFormation'] ?? '',
      'myResult': matchData['myResult'] ?? 0,
      'opponentResult': matchData['opponentResult'] ?? 0,
      'winningMatchesCount': matchData['winningMatchesCount'] ?? 0,
      'playerDetails': playerDetails,
      'image': teamData['image'] ?? '', // صورة الفريق
      'teamName': teamData['teamName'] ?? 'Unknown Team', // اسم الفريق
      'latitude': latitude,
      'longitude': longitude,
      'assisters': assisters,
      'goalsList': goalsList,
      'opponentTeamImage': opponentTeamImage, // صورة الفريق المنافس
    };
  }
}
