import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AllPlayersController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> addedPlayers = []; // قائمة اللاعبين المُضافين
  var _players = <Map<String, dynamic>>[].obs; // قائمة قابلة للمراقبة

  void addPlayer(Map<String, dynamic> player) {
    addedPlayers.add(player); // إضافة لاعب إلى القائمة
    print('Added Player: $player'); // طباعة اللاعب المضا
  }
  // دالة لجلب جميع اللاعبين
  RxInt playerCount = 0.obs;
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    QuerySnapshot playerSnapshot = await _firestore.collection('players').get();
    List<QueryDocumentSnapshot> playerDocuments = playerSnapshot.docs;

    List<Map<String, dynamic>> playersWithTeamName = [];

    // جلب بيانات الفرق لكل لاعب باستخدام Future.wait
    List<Future<DocumentSnapshot>> teamFutures = playerDocuments.map((playerDoc) {
      Map<String, dynamic> playerData = playerDoc.data() as Map<String, dynamic>;
      String teamId = playerData['teamId'];
      return _firestore.collection('team').doc(teamId).get();
    }).toList();

    List<DocumentSnapshot> teamSnapshots = await Future.wait(teamFutures);

    for (int i = 0; i < playerDocuments.length; i++) {
      Map<String, dynamic> playerData = playerDocuments[i].data() as Map<String, dynamic>;
      String teamName = teamSnapshots[i].exists ? teamSnapshots[i]['teamName'] : 'Unknown Team';
      String teamImage = teamSnapshots[i].exists ? teamSnapshots[i]['image'] : ''; // افترض أن "teamImage" هو حقل الصورة في مستند الفريق


      playerData['teamName'] = teamName;
      playerData['teamImage'] = teamImage;

      playersWithTeamName.add(playerData);
    }

    // ترتيب اللاعبين حسب الاسم الأول (غير حساس لحالة الأحرف)
    playersWithTeamName.sort((a, b) {
      return a['firstName'].toString().toLowerCase().compareTo(b['firstName'].toString().toLowerCase());
    });
    playerCount.value = playersWithTeamName.length;
    _players.value = playersWithTeamName;
    return playersWithTeamName;
  }



  List<Map<String, dynamic>> filterPlayersByAge(List<Map<String, dynamic>> players, int age) {
    return players.where((player) => player['age'] == age).toList();
  }






  // Future<List<Map<String, dynamic>>> getSchoolTeamPlayers() async {
  //   QuerySnapshot querySnapshot = await _firestore
  //       .collection('team')
  //       .where('teamType', isEqualTo: 'School Team') // شرط لتحديد نوع الفريق
  //       .get();
  //
  //   List<QueryDocumentSnapshot> documents = querySnapshot.docs;
  //   return documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
  // }
  //
  // Future<List<Map<String, dynamic>>> getNonSchoolTeamPlayers() async {
  //   QuerySnapshot querySnapshot = await _firestore
  //       .collection('team')
  //       .where('teamType', isNotEqualTo: 'School Team') // شرط لتحديد أن نوع الفريق ليس "School Team"
  //       .get();
  //
  //   List<QueryDocumentSnapshot> documents = querySnapshot.docs;
  //   return documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
  // }


  // Future<Map<String, dynamic>> getPlayerDetails(String playerId) async {
  // DocumentSnapshot<Map<String, dynamic>> playerSnapshot =
  // await FirebaseFirestore.instance.collection('players').doc(playerId).get();
  //
  // // التأكد من أن البيانات هي في النوع المناسب
  // Map<String, dynamic> playerData = playerSnapshot.data()!;
  //
  // return {
  // 'firstName': playerData['firstName'] ?? '',
  // 'lastName': playerData['lastName'] ?? '',
  // 'playerNumber': playerData['playerNumber'] != null ? playerData['playerNumber'] as int : 0,
  // 'height': playerData['height'] != null ? playerData['height'].toDouble() : 0.0,
  // 'weight': playerData['weight'] != null ? playerData['weight'].toDouble() : 0.0,
  // 'position': playerData['position'] ?? '',
  // 'image': playerData['image'] ?? '',
  // 'goals': playerData['goals'] != null ? playerData['goals'] as int : 0,
  // 'assists': playerData['assists'] != null ? playerData['assists'] as int : 0,
  // 'shotsOnTarget': playerData['shotsOnTarget'] != null ? playerData['shotsOnTarget'] as int : 0,
  // 'tackles': playerData['tackles'] != null ? playerData['tackles'] as int : 0,
  // 'interceptions': playerData['interceptions'] != null ? playerData['interceptions'] as int : 0,
  // 'passAccuracy': playerData['passAccuracy'] != null ? playerData['passAccuracy'].toDouble() : 0.0,
  // 'dribblesCompleted': playerData['dribblesCompleted'] != null ? playerData['dribblesCompleted'] as int : 0,
  // 'yellowCards': playerData['yellowCards'] != null ? playerData['yellowCards'] as int : 0,
  // 'redCards': playerData['redCards'] != null ? playerData['redCards'] as int : 0,
  // 'foulGoals': playerData['foulGoals'] != null ? playerData['foulGoals'] as int : 0,
  // 'penaltyGoals': playerData['penaltyGoals'] != null ? playerData['penaltyGoals'] as int : 0,
  // 'age': playerData['age'] != null ? playerData['age'] as int : 0,
  // 'city': playerData['city'] ?? '',
  // 'cleanSheets': playerData['cleanSheets'] != null ? playerData['cleanSheets'] as int : 0,
  // 'saves': playerData['saves'] != null ? playerData['saves'] as int : 0,
  // 'penaltiesSaved': playerData['penaltiesSaved'] != null ? playerData['penaltiesSaved'] as int : 0,
  // 'ownGoals': playerData['ownGoals'] != null ? playerData['ownGoals'] as int : 0,
  // 'goalsConceded': playerData['goalsConceded'] != null ? playerData['goalsConceded'] as int : 0,
  //   'achievements': playerData['achievements'] != null
  //       ? List<Map<String, dynamic>>.from(playerData['achievements'])
  //       : [],
  //   'videos': playerData['videos'] != null
  //       ? List<Map<String, dynamic>>.from(playerData['videos'])
  //       : [],
  // };
  // }
  Future<Map<String, dynamic>> getPlayerDetails(String playerId) async {
    DocumentSnapshot<Map<String, dynamic>> playerSnapshot =
    await FirebaseFirestore.instance.collection('players').doc(playerId).get();

    // التأكد من أن البيانات ليست فارغة وإعادتها كما هي
    Map<String, dynamic>? playerData = playerSnapshot.data();

    // معالجة الفيديوهات إذا كانت موجودة
    if (playerData['videos'] != null && playerData['videos'] is List) {
      playerData['videos'] = List<Map<String, String>>.from(
        playerData['videos'].map((video) => Map<String, String>.from(video as Map)),
      );
    } else {
      playerData['videos'] = []; // تعيين قيمة فارغة إذا لم تكن هناك فيديوهات
    }

    return playerData;
  }




}



